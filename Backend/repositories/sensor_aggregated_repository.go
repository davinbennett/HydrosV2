package repositories

import (
	"main/config"
	"main/models"
	"time"
)

func SaveAggregatedSensor(data models.SensorAggregate) string {
	if err := config.PostgresDB.Create(&data).Error; err != nil {
		return "Gagal menyimpan data sensor teragregasi"
	}
	return ""
}

func GetAggregatedSensorData(deviceID string, startDate, endDate *time.Time) (*models.SensorAggregate, string) {
	var result models.SensorAggregate

	query := config.PostgresDB.Where("device_id = ?", deviceID)

	if startDate != nil {
		query = query.Where("interval_start >= ?", *startDate)
	}
	if endDate != nil {
		query = query.Where("interval_end <= ?", *endDate)
	}

	if err := query.Order("interval_end desc").First(&result).Error; err != nil {
		return nil, "Gagal mengambil data sensor teragregasi"
	}

	return &result, ""
}
