package services

import (
	"main/repositories"
	"time"
)

func GetDeviceAlarms(deviceID string) (map[string]interface{}, string) {
	alarms, err := repositories.FindAlarmsByDeviceID(deviceID)
	if err != "" {
		return nil, err
	}

	var nextAlarm *time.Time
	list := make([]map[string]interface{}, 0, len(alarms))

	for _, alarm := range alarms {
		list = append(list, map[string]any{
			"id":            alarm.ID,
			"is_executed":   alarm.IsExecute,
			"schedule_time": alarm.ScheduleTime.Format(time.RFC3339),
		})

		if !alarm.IsExecute && nextAlarm == nil {
			nextAlarm = alarm.ScheduleTime
		}
	}

	var next string
	if nextAlarm != nil {
		next = nextAlarm.Format(time.RFC3339)
	}

	return map[string]interface{}{
		"next_alarm": next,
		"list_alarm": list,
	}, ""
}

func AddAlarm(deviceID string, scheduleTime time.Time) string {
	return repositories.CreateAlarm(deviceID, scheduleTime)
}

func DeleteAlarm(deviceID string, scheduleTime time.Time) string {
	return repositories.DeleteAlarmBySchedule(deviceID, scheduleTime)
}
