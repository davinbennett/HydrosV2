package services

import (
	"main/models"
	"main/repositories"

	"main/utils"
)


func GetSensorAggregate(deviceID uint, today, lastday, month bool, start, end string) (*models.SensorAggregate, error) {
	startDate, endDate, err := utils.ResolveDateRange(today, lastday, month, start, end)
	if err != nil {
		return nil, err
	}
	return repositories.GetAggregatedSensorData(deviceID, startDate, endDate)
}