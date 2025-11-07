package services

import (
	"encoding/json"
	"log"
	"main/config"
	"main/infrastructure/mqtt"
	"main/repositories"
	"time"
)

func GetDeviceAlarms(deviceID string) (map[string]any, string) {
	alarms, err := repositories.FindAlarmsByDeviceID(deviceID)
	if err != "" {
		return nil, err
	}

	var nextAlarm *time.Time
	list := make([]map[string]any, 0, len(alarms))

	for _, alarm := range alarms {
		list = append(list, map[string]any{
			"id":            alarm.ID,
			"schedule_time": alarm.ScheduleTime.Format(time.RFC3339),
		})

		if nextAlarm == nil || alarm.ScheduleTime.Before(*nextAlarm) {
			nextAlarm = alarm.ScheduleTime
		}
	}

	var next string
	if nextAlarm != nil {
		next = nextAlarm.Format(time.RFC3339)
	}

	return map[string]any{
		"next_alarm": next,
		"list_alarm": list,
	}, ""
}

func AddAlarm(deviceID string, scheduleTime time.Time, durationOn, repeatType int) string {
	// 0. Cek status koneksi device
	status := mqtt.GetDeviceStatus(deviceID)
	if status != mqtt.StatusStable {
		log.Printf("[SERVICE] Device %s not connected (status: %s)", deviceID, status)
		return "Failed to add alarm. Please try again"
	}

	// 1. Simpan alarm ke DB
	alarmID, err := repositories.CreateAlarm(deviceID, scheduleTime, durationOn, repeatType)
	if err != "" {
		return err
	}

	// 2. Payload untuk dikirim ke device
	payload := map[string]any{
		"action":        1, // 1 = add
		"alarm_id":      alarmID,
		"schedule_time": scheduleTime.Format("15:04"), // HH:mm
		"duration_on":   durationOn,
		"repeat_type":   repeatType, // 1=once,2=daily,3=weekly
	}

	data, err2 := json.Marshal(payload)
	if err2 != nil {
		log.Printf("[SERVICE] Failed to marshal alarm payload: %v", err2)
		return "Failed to prepare alarm payload"
	}

	// 3. Publish ke device via MQTT
	res := mqtt.PublishAlarmControl(config.MQTTClients, deviceID, string(data))
	if res != "" {
		return res
	}

	log.Printf("[SERVICE] Alarm added & published to device %s: %s", deviceID, string(data))
	return ""
}

func UpdateAlarm(deviceID, alarmID string, scheduleTime time.Time, durationOn, repeatType int) string {
	// 0. Cek status koneksi device
	status := mqtt.GetDeviceStatus(deviceID)
	if status != mqtt.StatusStable {
		log.Printf("[SERVICE] Device %s not connected (status: %s)", deviceID, status)
		return "Failed to update alarm. Please try again"
	}

	// 1. Update alarm di DB
	err := repositories.UpdateAlarm(alarmID, scheduleTime, durationOn, repeatType)
	if err != "" {
		return err
	}

	// 2. Buat payload untuk device
	payload := map[string]any{
		"action":        2, // 2 = update
		"alarm_id":      alarmID,
		"schedule_time": scheduleTime.Format("15:04"),
		"duration_on":   durationOn,
		"repeat_type":   repeatType,
	}

	data, err2 := json.Marshal(payload)
	if err2 != nil {
		log.Printf("[SERVICE] Failed to marshal update alarm payload: %v", err2)
		return "Failed to prepare update alarm payload"
	}

	// 3. Publish ke MQTT
	res := mqtt.PublishAlarmControl(config.MQTTClients, deviceID, string(data))
	if res != "" {
		return res
	}

	log.Printf("[SERVICE] Alarm updated & published to device %s: %s", deviceID, string(data))
	return ""
}

func DeleteAlarm(deviceId, alarmID string) string {
	// 0. Cek status koneksi device
	status := mqtt.GetDeviceStatus(deviceId)
	if status != mqtt.StatusStable {
		log.Printf("[SERVICE] Device %s not connected (status: %s)", deviceId, status)
		return "Failed to delete alarm. Please try again"
	}

	// 1. Hapus alarm dari DB
	err := repositories.DeleteAlarmBySchedule(alarmID)
	if err != "" {
		return err
	}

	// 2. Payload delete
	payload := map[string]any{
		"action":   3, // 3 = delete
		"alarm_id": alarmID,
	}

	data, err2 := json.Marshal(payload)
	if err2 != nil {
		log.Printf("[SERVICE] Failed to marshal delete alarm payload: %v", err2)
		return "Failed to prepare delete alarm payload"
	}

	// 3. Publish ke device via MQTT
	res := mqtt.PublishAlarmControl(config.MQTTClients, deviceId, string(data))
	if res != "" {
		return res
	}

	log.Printf("[SERVICE] Alarm deleted & published to device: %s", string(data))
	return ""
}

func UpdateEnabled(alarmID string, isEnabled bool, deviceID string) string {
	// 0. Cek status koneksi device
	status := mqtt.GetDeviceStatus(deviceID)
	if status != mqtt.StatusStable {
		log.Printf("[SERVICE] Device %s not connected (status: %s)", deviceID, status)
		return "Failed to update alarm. Please try again"
	}

	// 1. Update enabled di DB
	err := repositories.UpdateEnableBySchedule(alarmID, isEnabled)
	if err != "" {
		return err
	}

	// 2. Ambil data alarm untuk dikirim jika diaktifkan
	if isEnabled {
		alarm, err2 := repositories.GetAlarmByID(alarmID)
		if err2 != nil {
			log.Printf("[SERVICE] Failed to get alarm %s: %v", alarmID, err2)
			return "Failed to retrieve alarm details"
		}

		payload := map[string]any{
			"action":        1, // 1 = add
			"alarm_id":      alarmID,
			"schedule_time": alarm.ScheduleTime.Format("15:04"), // HH:mm
			"duration_on":   alarm.DurationOn,
			"repeat_type":   alarm.RepeatType, // 1=once,2=daily,3=weekly
		}

		data, err3 := json.Marshal(payload)
		if err3 != nil {
			log.Printf("[SERVICE] Failed to marshal re-add alarm payload: %v", err3)
			return "Failed to prepare alarm payload"
		}

		// Publish ke device seperti AddAlarm
		res := mqtt.PublishAlarmControl(config.MQTTClients, deviceID, string(data))
		if res != "" {
			return res
		}

		log.Printf("[SERVICE] Alarm re-enabled & published to device %s: %s", deviceID, string(data))
		return ""
	}

	// 3. Jika isEnabled = false, kirim disable signal saja
	payload := map[string]any{
		"alarm_id":   alarmID,
		"is_enabled": false,
	}

	data, err2 := json.Marshal(payload)
	if err2 != nil {
		log.Printf("[SERVICE] Failed to marshal disable alarm payload: %v", err2)
		return "Failed to prepare disable alarm payload"
	}

	res := mqtt.PublishEnabledAlarm(config.MQTTClients, deviceID, string(data))
	if res != "" {
		return res
	}

	log.Printf("[SERVICE] Alarm disabled & published to device %s: %s", deviceID, string(data))
	return ""
}

