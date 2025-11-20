package repositories

import (
	"errors"
	"main/config"
	"main/models"
	"time"

	"gorm.io/gorm"
)

func SaveAggregatedSensor(data models.SensorAggregate) string {
	if err := config.PostgresDB.Create(&data).Error; err != nil {
		return "Gagal menyimpan data sensor teragregasi"
	}
	return ""
}

func GetAggregatedSensorData(deviceID string, startDate, endDate *time.Time) (*models.SensorAggregate, string) {
	var result models.SensorAggregate

	query := config.PostgresDB.
		Model(&models.SensorAggregate{}).
		Select("AVG(avg_temperature) AS avg_temperature, AVG(avg_humidity) AS avg_humidity, AVG(avg_soil_moisture) AS avg_soil_moisture")

	query = query.Where("device_id = ?", deviceID)

	if startDate != nil {
		query = query.Where("interval_end >= ?", *startDate)
	}
	if endDate != nil {
		query = query.Where("interval_end <= ?", *endDate)
	}

	err := query.Scan(&result).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return &models.SensorAggregate{
			AvgTemperature:  0.0,
			AvgHumidity:     0.0,
			AvgSoilMoisture: 0.0,
		}, ""
	}

	if err != nil {
		return nil, "Failed to calculate aggregated averages"
	}

	return &result, ""
}
