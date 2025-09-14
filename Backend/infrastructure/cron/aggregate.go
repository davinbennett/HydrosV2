package cron

import (
	"encoding/json"
	"fmt"
	"main/dto"
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
		return "Gagal mengambil data sensor dari Redis"
	}
	if len(dataList) == 0 {
		return "" // tidak ada data, bukan error
	}

	var totalTemp, totalHumid, totalSoil float32
	for _, raw := range dataList {
		var sensor dto.SensorData
		if e := json.Unmarshal([]byte(raw), &sensor); e != nil {
			continue // skip data yang corrupt
		}
		totalTemp += sensor.Temperature
		totalHumid += sensor.Humidity
		totalSoil += sensor.SoilMoisture
	}

	n := float32(len(dataList))
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
		return "Gagal menyimpan hasil agregasi sensor"
	}

	// Bersihkan Redis setelah agregasi
	if msg := repositories.DeleteSensorData(redisKey); msg != "" {
		return "Gagal menghapus data sensor dari Redis"
	}

	return ""
}