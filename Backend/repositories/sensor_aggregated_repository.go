package repositories

import (
	"main/config"
	"main/models"
	"time"
)

func SaveAggregatedSensor(data models.SensorAggregate) error {
	return config.PostgresDB.Create(&data).Error
}

func GetAggregatedSensorData(deviceID uint, startDate, endDate *time.Time) (*models.SensorAggregate, error) {
	var result models.SensorAggregate

	query := config.PostgresDB.Where("device_id = ?", deviceID)

	if startDate != nil {
		query = query.Where("interval_start >= ?", *startDate)
	}
	if endDate != nil {
		query = query.Where("interval_end <= ?", *endDate)
	}

	err := query.Order("interval_end desc").First(&result).Error
	if err != nil {
		return nil, err
	}
	
	return &result, nil
}