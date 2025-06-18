package repositories

import (
	"time"
	"main/models"
	"main/config"
)

func GetTodayPumpUsage(deviceID string) (int64, error) {
	var count int64

	today := time.Now().Truncate(24 * time.Hour)

	err := config.PostgresDB.Model(&models.PumpLog{}).
		Where("device_id = ? AND created_at >= ?", deviceID, today).
		Count(&count).Error

	return count, err
}

func GetLastWateredTime(deviceID string) (*models.PumpLog, error) {
	var pumpLog models.PumpLog
	err := config.PostgresDB.
		Where("device_id = ?", deviceID).
		Order("updated_at DESC").
		First(&pumpLog).Error

	if err != nil {
		return nil, err
	}

	return &pumpLog, nil
}

func GetPumpStartTimes(deviceID string) ([]map[string]interface{}, error) {
	var results []map[string]interface{}

	err := config.PostgresDB.Model(&models.PumpLog{}).
		Select("start_time").
		Where("device_id = ?", deviceID).
		Order("start_time DESC").
		Find(&results).Error

	return results, err
}

func FindPumpLog(deviceID string, from, to *time.Time, limit int) ([]models.PumpLog, error) {
	var logs []models.PumpLog

	query := config.PostgresDB.Where("device_id = ?", deviceID)

	if from != nil && to != nil {
		query = query.Where("start_time >= ? AND end_time <= ?", *from, *to)
	}

	err := query.Order("start_time DESC").Limit(limit).Find(&logs).Error
	return logs, err
}

func DeletePumpLogByID(id string) error {
	return config.PostgresDB.Delete(&models.PumpLog{}, id).Error
}
