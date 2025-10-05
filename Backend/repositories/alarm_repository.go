package repositories

import (
	"log"
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

func CreateAlarm(deviceID string, scheduleTime time.Time, durationOn, repeatType int) (uint, string) {
	alarm := models.Alarm{
		DeviceID:     deviceID,
		ScheduleTime: &scheduleTime,
		DurationOn:   durationOn,
		RepeatType:   repeatType,
	}

	if err := config.PostgresDB.Create(&alarm).Error; err != nil {
		return 0, "Failed to create alarm. Please try again."
	}
	return alarm.ID, ""
}

func UpdateAlarm(alarmID string, scheduleTime time.Time, durationOn, repeatType int) string {
	alarm := models.Alarm{
		ScheduleTime: &scheduleTime,
		DurationOn:   durationOn,
		RepeatType:   repeatType,
		UpdatedAt:    time.Now(),
	}

	err := config.PostgresDB.
		Model(&models.Alarm{}).
		Where("id = ?", alarmID).
		Updates(alarm)

	if err.Error != nil {
		log.Printf("[REPOSITORY] Failed to update alarm %s: %v", alarmID, err)
		return "Failed to update alarm in database"
	}

	if err.RowsAffected == 0 {
		log.Printf("[REPOSITORY] Alarm ID %s not found in database", alarmID)
		return "Alarm ID not found in database"
	}

	return ""
}


func DeleteAlarmBySchedule(alarmID string) string {
	if err := config.PostgresDB.
		Where("id = ?", alarmID).
		Delete(&models.Alarm{}).Error; err != nil {
		return "Failed to delete alarm. Please try again."
	}
	return ""
}

func UpdateEnableBySchedule(alarmID string, isEnabled bool) string {
	if err := config.PostgresDB.
		Model(&models.Alarm{}).
		Where("id = ?", alarmID).
		Update("is_enabled", isEnabled).Error; err != nil {
		return "Failed to update alarm status. Please try again."
	}
	return ""
}

func GetAlarmByID(alarmID string) (*models.Alarm, error) {
	var alarm models.Alarm
	if err := config.PostgresDB.Where("id = ?", alarmID).First(&alarm).Error; err != nil {
		return nil, err
	}
	return &alarm, nil
}
