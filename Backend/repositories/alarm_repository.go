package repositories

import (
	"main/config"
	"main/models"
)

func FindAlarmsByDeviceID(deviceID string) ([]models.Alarm, error) {
	var alarms []models.Alarm
	err := config.PostgresDB.
		Where("device_id = ?", deviceID).
		Order("schedule_time ASC").
		Find(&alarms).Error
	return alarms, err
}
