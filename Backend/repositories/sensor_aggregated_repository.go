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

	query := config.PostgresDB.Where("device_id = ?", deviceID)

	if startDate != nil {
		query = query.Where("interval_start >= ?", *startDate)
	}
	if endDate != nil {
		query = query.Where("interval_end <= ?", *endDate)
	}

	err := query.Order("interval_end desc").First(&result).Error

	// Jika tidak ada record → tetap return success tapi dengan nilai default
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return &models.SensorAggregate{
			AvgTemperature:   0.0,
			AvgHumidity:      0.0,
			AvgSoilMoisture:  0.0,
			IntervalStart:    nil,
			IntervalEnd:      nil,
		}, ""
	}

	// Jika error lain → return gagal
	if err != nil {
		return nil, "Failed to Get Environmental Averages"
	}

	return &result, ""
}
