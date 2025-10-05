package cron

import (
	"encoding/json"
	"fmt"
	"log"
	"main/models"
	"main/repositories"
	"sync"
	"time"
)

// AggregateSensorData Tiap 10 menit
func AggregateSensorData() string {
	deviceIDs, err := repositories.GetAllDeviceIDs()
	if err != "" {
		return "Gagal mengambil daftar device"
	}

	var wg sync.WaitGroup
	errChan := make(chan string, len(deviceIDs))

	for _, deviceID := range deviceIDs {
		wg.Add(1)
		go func(did string) {
			defer wg.Done()
			if msg := aggregateDeviceData(did); msg != "" {
				errChan <- msg
			}
		}(deviceID)
	}

	wg.Wait()
	close(errChan)

	// ambil error pertama yang muncul
	for e := range errChan {
		return e
	}

	return ""
}


func aggregateDeviceData(deviceID string) string {
	// Ambil data dari Redis
	redisKey := fmt.Sprintf("sensor/%s", deviceID)
	dataList, err := repositories.GetSensorDataList(redisKey)
	if err != "" {
		return fmt.Sprintf("Device %s: gagal ambil data sensor dari Redis", deviceID)
	}
	if len(dataList) == 0 {
		log.Printf("[CRON] Device %s tidak ada data untuk agregasi", deviceID)
		return "" // tidak ada data, bukan error
	}

	var totalTemp, totalHumid, totalSoil float64
	for _, raw := range dataList {
		var data struct {
			Type      int    `json:"type"`
			DeviceID  string `json:"device_id"`
			Temperature float64 `json:"temperature"`
			Humidity    float64 `json:"humidity"`
			SoilMoisture float64 `json:"soil_moisture"`
		}
		if e := json.Unmarshal([]byte(raw), &data); e != nil {
			log.Printf("[CRON] Skip data corrupt di device %s: %v", deviceID, e)
			continue // skip data yang corrupt
		}
		totalTemp += data.Temperature
		totalHumid += data.Humidity
		totalSoil += data.SoilMoisture
	}

	n := float64(len(dataList))
	now := time.Now()
	start := now.Add(-10 * time.Minute)

	agg := models.SensorAggregate{
		DeviceID:        deviceID,
		AvgTemperature:  totalTemp / n,
		AvgHumidity:     totalHumid / n,
		AvgSoilMoisture: totalSoil / n,
		IntervalStart:   &start,
		IntervalEnd:     &now,
	}

	if msg := repositories.SaveAggregatedSensor(agg); msg != "" {
		return fmt.Sprintf("Device %s: gagal simpan hasil agregasi", deviceID)
	}

	// Bersihkan Redis setelah agregasi
	if msg := repositories.DeleteSensorData(redisKey); msg != "" {
		return fmt.Sprintf("Device %s: gagal hapus data Redis", deviceID)
	}

	log.Printf("[CRON] Device %s agregasi berhasil disimpan (%d data)", deviceID, len(dataList))
	return ""
}