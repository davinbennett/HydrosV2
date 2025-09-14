package repositories

import (
	"main/config"
	"main/models"
	"time"
)

func GetTodayPumpUsage(deviceID string) (int64, string) {
	var count int64
	today := time.Now().Truncate(24 * time.Hour)

	if err := config.PostgresDB.Model(&models.PumpLog{}).
		Where("device_id = ? AND created_at >= ?", deviceID, today).
		Count(&count).Error; err != nil {
		return 0, "Failed to get today's pump usage. Please try again later."
	}
	return count, ""
}

func GetLastWateredTime(deviceID string) (*models.PumpLog, string) {
	var pumpLog models.PumpLog
	if err := config.PostgresDB.
		Where("device_id = ?", deviceID).
		Order("updated_at DESC").
		First(&pumpLog).Error; err != nil {
		return nil, "Failed to get last watered time."
	}
	return &pumpLog, ""
}

func GetPumpStartTimes(deviceID string) ([]map[string]any, string) {
	var results []map[string]any
	if err := config.PostgresDB.Model(&models.PumpLog{}).
		Select("start_time").
		Where("device_id = ?", deviceID).
		Order("start_time DESC").
		Find(&results).Error; err != nil {
		return nil, "Failed to get pump start times."
	}
	return results, ""
}

func FindPumpLog(deviceID string, from, to *time.Time, limit int) ([]models.PumpLog, string) {
	var logs []models.PumpLog

	query := config.PostgresDB.Where("device_id = ?", deviceID)
	if from != nil && to != nil {
		query = query.Where("start_time >= ? AND end_time <= ?", *from, *to)
	}

	if err := query.Order("start_time DESC").Limit(limit).Find(&logs).Error; err != nil {
		return nil, "Failed to get pump logs. Please try again later."
	}
	return logs, ""
}

func DeletePumpLogByID(id string) string {
	if err := config.PostgresDB.Delete(&models.PumpLog{}, id).Error; err != nil {
		return "Failed to delete pump log."
	}
	return ""
}
