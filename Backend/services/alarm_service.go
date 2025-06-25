package services

import (
	"main/repositories"
	"strconv"
	"time"
)

func GetDeviceAlarms(deviceID string) (map[string]interface{}, error) {
	alarms, err := repositories.FindAlarmsByDeviceID(deviceID)
	if err != nil {
		return nil, err
	}

	var nextAlarm *time.Time
	list := make([]map[string]interface{}, 0, len(alarms))

	for _, alarm := range alarms {
		list = append(list, map[string]interface{}{
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
	}, nil
}

func AddAlarm(deviceIDStr string, scheduleTime time.Time) error {
	deviceID, err := strconv.Atoi(deviceIDStr)
	if err != nil {
		return err
	}

	return repositories.CreateAlarm(uint(deviceID), scheduleTime)
}


func DeleteAlarm(deviceIDStr string, scheduleTime time.Time) error {
	deviceID, err := strconv.Atoi(deviceIDStr)
	if err != nil {
		return err
	}
	return repositories.DeleteAlarmBySchedule(uint(deviceID), scheduleTime)
}