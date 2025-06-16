package cron

import (
	"encoding/json"
	"fmt"
	"log"
	"main/models"
	"main/repositories"
	"time"
	"main/dto"
)

// AggregateSensorData Tiap 10 menit
func AggregateSensorData() {
	deviceIDs, err := repositories.GetAllDeviceIDs()
	if err != nil {
		log.Println("Failed to get device IDs:", err)
		return
	}

	for _, deviceID := range deviceIDs {
		go aggregateDeviceData(deviceID)
	}
}

func aggregateDeviceData(deviceID uint) {
	// Ambil data dari Redis
	redisKey := fmt.Sprintf("sensor/%d", deviceID)
	dataList, err := repositories.GetSensorDataList(redisKey)
	if err != nil {
		log.Printf("Error fetching Redis data for device %d: %v", deviceID, err)
		return
	}
	if len(dataList) == 0 {
		log.Printf("No data to aggregate for device %d", deviceID)
		return
	}

	var totalTemp, totalHumid, totalSoil float32
	for _, raw := range dataList {
		var sensor dto.SensorData
		if err := json.Unmarshal([]byte(raw), &sensor); err != nil {
			continue
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

	if err := repositories.SaveAggregatedSensor(agg); err != nil {
		log.Printf("Failed to save aggregated sensor data: %v", err)
		return
	}

	// Bersihkan Redis setelah agregasi
	if err := repositories.DeleteSensorData(redisKey); err != nil {
		log.Printf("Failed to clear Redis key %s: %v", redisKey, err)
	}
}
