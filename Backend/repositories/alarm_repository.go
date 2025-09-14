package repositories

import (
	"main/config"
	"main/models"
	"time"
)

func FindAlarmsByDeviceID(deviceID string) ([]models.Alarm, string) {
	var alarms []models.Alarm
	err := config.PostgresDB.
		Where("device_id = ?", deviceID).
		Order("schedule_time ASC").
		Find(&alarms).Error
	if err != nil {
		return nil, "Failed to retrieve alarms. Please try again later."
	}
	return alarms, ""
}

func CreateAlarm(deviceID string, scheduleTime time.Time) string {
	alarm := models.Alarm{
		DeviceID:     deviceID,
		ScheduleTime: &scheduleTime,
	}
	if err := config.PostgresDB.Create(&alarm).Error; err != nil {
		return "Failed to create alarm. Please try again."
	}
	return ""
}

func DeleteAlarmBySchedule(deviceID string, scheduleTime time.Time) string {
	if err := config.PostgresDB.
		Where("device_id = ? AND schedule_time = ?", deviceID, scheduleTime).
		Delete(&models.Alarm{}).Error; err != nil {
		return "Failed to delete alarm. Please try again."
	}
	return ""
}