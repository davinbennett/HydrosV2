package repositories

import (
	"main/config"
	"main/models"
	"time"
)

func FindAlarmsByDeviceID(deviceID string) ([]models.Alarm, error) {
	var alarms []models.Alarm
	err := config.PostgresDB.
		Where("device_id = ?", deviceID).
		Order("schedule_time ASC").
		Find(&alarms).Error
	return alarms, err
}

func CreateAlarm(deviceID uint, scheduleTime time.Time) error {
	alarm := models.Alarm{
		DeviceID:     deviceID,
		ScheduleTime: &scheduleTime,
	}
	return config.PostgresDB.Create(&alarm).Error
}

func DeleteAlarmBySchedule(deviceID uint, scheduleTime time.Time) error {
	return config.PostgresDB.
		Where("device_id = ? AND schedule_time = ?", deviceID, scheduleTime).
		Delete(&models.Alarm{}).Error
}