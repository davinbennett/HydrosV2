package repositories

import (
	"main/config"
	"main/models"
)

func SaveAggregatedSensor(data models.SensorAggregate) error {
	return config.PostgresDB.Create(&data).Error
}
