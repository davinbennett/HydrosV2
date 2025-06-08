package services

import (
	"main/repositories"
	"time"
)

func GetPumpUsageToday(deviceID string) (int64, error) {
	return repositories.GetTodayPumpUsage(deviceID)
}

func GetLastWatered(deviceID string) (*time.Time, error) {
	pumpLog, err := repositories.GetLastWateredTime(deviceID)
	if err != nil {
		return nil, err
	}

	return &pumpLog.UpdatedAt, nil
}

func GetPumpStartTimes(deviceID string) ([]map[string]interface{}, error) {
	return repositories.GetPumpStartTimes(deviceID)
}
