package services

import (
	"main/models"
	"main/repositories"

	"main/utils"
)


func GetSensorAggregate(deviceID string, today, lastday, month bool, start, end string) (*models.SensorAggregate, string) {
	startDate, endDate, err := utils.ResolveDateRange(today, lastday, month, start, end)
	if err != nil {
		return nil, err.Error()
	}

	data, err2 := repositories.GetAggregatedSensorData(deviceID, startDate, endDate)
	return data, err2
}