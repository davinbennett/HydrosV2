package mqtt

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"main/config"
	"main/infrastructure/fcm"
	"main/models"
	"main/repositories"
	"main/utils"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func SubscribeTopics(client mqtt.Client, deviceID string) string {
	topics := map[string]mqtt.MessageHandler{

		// Topic: from-esp/{deviceid}/sensor
		fmt.Sprintf("from-esp/%s/sensor", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handleSensorData(c, m); err != "" {
				fmt.Printf("[MQTT] Sensor handler error (device %s): %s\n", deviceID, err)
			}
		},

		// Topic: from-esp/{deviceid}/pump-status
		fmt.Sprintf("from-esp/%s/pump-status", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handlePumpStatus(c, m); err != "" {
				fmt.Printf("[MQTT] Pump handler error (device %s): %s\n", deviceID, err)
			}
		},

		// Topic: from-esp/{deviceid}/status-device
		fmt.Sprintf("from-esp/%s/status-device", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handleDeviceStatus(c, m); err != "" {
				fmt.Printf("[MQTT] Status Device handler error (device %s): %s\n", deviceID, err)
			}
		},

		// Topic: from-esp/{deviceid}/delete-alarm
		fmt.Sprintf("from-esp/%s/delete-alarm", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handleDeleteAlarm(c, m); err != "" {
				fmt.Printf("[MQTT] Delete Alarm handler error (device %s): %s\n", deviceID, err)
			}
		},
	}

	for topic, handler := range topics {
		if token := client.Subscribe(topic, 1, handler); token.Wait() && token.Error() != nil {
			return "Failed to subscribe to MQTT topic. Please try again later."
		}
	}

	return ""
}

// status device : connected / disconnected
func handleDeviceStatus(client mqtt.Client, msg mqtt.Message) string {
	var data struct {
		Type     int    `json:"type"`
		DeviceID string `json:"device_id"`
		Status   string `json:"status"`
	}

	if err := json.Unmarshal(msg.Payload(), &data); err != nil {
		return "invalid status payload"
	}

	log.Printf("[MQTT] Type:%d | Device:%s | Status:%v\n", data.Type, data.DeviceID, data.Status)

	// Simpan ke global map
	SetDeviceStatus(data.DeviceID, DeviceStatus(data.Status))

	wsPayload := map[string]any{
		"type":      "device_status",
		"device_id": data.DeviceID,
		"data": map[string]any{
			"status": data.Status,
		},
	}

	jsonMsg, err := json.Marshal(wsPayload)
	if err != nil {
		return "failed to marshal WS payload"
	}

	log.Printf("WS > status device > jsonMsg:%s\n", jsonMsg)

	// Kirim ke frontend (non-blocking)
	go func() {
		config.Broadcast <- jsonMsg
	}()

	return ""
}

func handleSensorData(client mqtt.Client, msg mqtt.Message) string {
	var data struct {
		Type         int     `json:"type"`
		DeviceID     string  `json:"device_id"`
		Temperature  float64 `json:"temperature"`
		Humidity     float64 `json:"humidity"`
		SoilMoisture float64 `json:"soil_moisture"`
	}

	if err := json.Unmarshal(msg.Payload(), &data); err != nil {
		return "invalid status payload"
	}

	log.Printf("[MQTT] Sensor data | Device Id: %s | Type: %d | Temperature: %.2f | Humidity: %.2f | Soil: %.2f\n\n", data.DeviceID, data.Type, data.Temperature, data.Humidity, data.SoilMoisture)

	key := fmt.Sprintf("sensor/%s", data.DeviceID) // key: sensor/{deviceid}
	if err := repositories.SaveSensorData(key, data); err != "" {
		return "Failed to save sensor data. Please try again later."
	}

	// ! SEND TO WS
	wsPayload := map[string]any{
		"type":      "sensor",
		"device_id": data.DeviceID,
		"data": map[string]any{
			"temperature": data.Temperature,
			"humidity":    data.Humidity,
			"soil":        data.SoilMoisture,
		},
	}

	jsonMsg, err := json.Marshal(wsPayload)
	if err != nil {
		return "Failed to process sensor data for broadcast."
	}

	log.Printf("WS > sensor data > jsonMsg:%s\n", jsonMsg)
	config.Broadcast <- jsonMsg

	return ""
}

func handlePumpStatus(client mqtt.Client, msg mqtt.Message) string {
	var data struct {
		Type       int     `json:"type"`
		DeviceID   string  `json:"device_id"`
		PumpStatus int     `json:"pump_status"` // 1: ON, 2: OFF
		ControlBy  int     `json:"control_by"`
		Time       int64   `json:"time"` // format ISO8601 string
		SoilValue  float64 `json:"soil_value"`
	}

	log.Println("MS PAYLOAD:", string(msg.Payload()))
	// Unmarshal JSON ke struct
	if err := json.Unmarshal(msg.Payload(), &data); err != nil {
		return "Failed to process pump status data. Please try again later."
	}

	log.Printf("[MQTT] Pump status | Device: %s | Pump Status: %d | ControlBy: %d | Time: %s | SoilValue: %.2f\n",
		data.DeviceID, data.PumpStatus, data.ControlBy, time.Unix(data.Time, 0), data.SoilValue)

	// Parse waktu
	t := time.Unix(data.Time, 0)
	log.Printf("Parsed Time: %s", t.Format(time.RFC3339))

	// --- Ambil status pompa dari DB ---
	currentStatus, err := repositories.GetPumpStatusById(data.DeviceID)
	if err != "" {
		log.Printf("[DB] Failed to fetch current pump status: %v", err)
		return "Failed to fetch current pump status"
	}

	// --- Kalau status sama, abaikan ---
	newStatus := (data.PumpStatus == 1) // true kalau ON
	if currentStatus == newStatus {
		log.Printf("[MQTT] Ignored duplicate pump status, no state change.")
		return ""
	}

	// 🔽 AMBIL USER ID DARI DEVICE
	userID, errUser := repositories.GetUserIDByDeviceID(data.DeviceID)
	if errUser != "" {
		log.Printf("[DB] Failed to get userID: %v", errUser)
	}

	// ---- Update DB ----
	switch data.PumpStatus {
	case 1:
		// Pompa ON → buat PumpLog baru
		err := repositories.CreatePumpLog(data.DeviceID, data.SoilValue, data.ControlBy, t)
		if err != "" {
			log.Printf("[DB] Failed to create PumpLog: %v", err)
		}

		// Update Device.isOn = true
		if err := repositories.UpdatePumpStatus(data.DeviceID, true); err != "" {
			log.Printf("[DB] Failed to update device status: %v", err)
		}

		// ✅ SEND FCM: POMPA ON
		if errUser == "" {
			sourceTitle, sourceDesc := utils.GetPumpControlSource(data.ControlBy)

			title := "🚿 Pump Activated " + sourceTitle
			body  := "Pump has been turned ON. " + sourceDesc

			// 1. SIMPAN KE DATABASE NOTIFICATION
			notif := models.Notification{
				UserID:   userID,
				DeviceID: data.DeviceID,
				Title:    title,
				Body:     body,
				Type:     "pump_on",
			}

			notifID, err := repositories.CreateNotification(&notif)
			if err != "" {
				log.Println("❌ Failed to create notification:", err)
			}

			// 2. KIRIM FCM
			go fcm.SendFCMToUser(
				userID,
				title,
				body,
				map[string]string{
					"type":        "pump_on",
					"device_id":  data.DeviceID,
					"control_by": fmt.Sprintf("%d", data.ControlBy),
					"notification_id": fmt.Sprintf("%d", notifID),
				},
			)
		}

	case 2:
		// Pompa OFF → update PumpLog terakhir
		err := repositories.UpdatePumpLog(data.DeviceID, data.SoilValue, t)
		if err != "" {
			log.Printf("[DB] Failed to update PumpLog: %v", err)
		}

		// Update Device.is_active_pump = false
		if err := repositories.UpdatePumpStatus(data.DeviceID, false); err != "" {
			log.Printf("[DB] Failed to update device status: %v", err)
		}

		// ✅ SEND FCM: POMPA OFF
		userID, errUser := repositories.GetUserIDByDeviceID(data.DeviceID)
		if errUser == "" {
			sourceTitle, sourceDesc := utils.GetPumpControlSource(data.ControlBy)

			title := "⛔ Pump Stopped " + sourceTitle
			body := "Pump has been turned OFF. " + sourceDesc

			// 1. SIMPAN KE DATABASE NOTIFICATION
			notif := models.Notification{
				UserID:   userID,
				DeviceID: data.DeviceID,
				Title:    title,
				Body:     body,
				Type:     "pump_off",
			}

			notifID, err := repositories.CreateNotification(&notif)
			if err != "" {
				log.Println("❌ Failed to create notification:", err)
			}

			// 2. KIRIM FCM
			go fcm.SendFCMToUser(
				userID,
				title,
				body,
				map[string]string{
					"type":        "pump_off",
					"device_id":  data.DeviceID,
					"control_by": fmt.Sprintf("%d", data.ControlBy),
					"notification_id": fmt.Sprintf("%d", notifID),
				},
			)
		}

	}

	// ! SEND TO WS
	wsPayload := map[string]any{
		"type":      "pump_status",
		"device_id": data.DeviceID,
		"data": map[string]any{
			"pump_status": data.PumpStatus,
			"control_by":  data.ControlBy,
			"time":        data.Time,
		},
	}

	jsonMsg, marshalErr := json.Marshal(wsPayload)
	if marshalErr != nil {
		return "Failed to process pump status for broadcast."
	}

	log.Printf("WS > pump status > jsonMsg:%s\n", jsonMsg)
	config.Broadcast <- jsonMsg
	return ""
}

func handleDeleteAlarm(client mqtt.Client, msg mqtt.Message) string {
	var data struct {
		DeviceID string `json:"device_id"`
		AlarmID  string `json:"alarm_id"`
	}

	// Unmarshal JSON ke struct
	if err := json.Unmarshal(msg.Payload(), &data); err != nil {
		return "Failed to process delete alarm data. Please try again later."
	}

	log.Printf("[MQTT] Delete alarmid : %s", data.AlarmID)

	err := repositories.UpdateEnableBySchedule(data.AlarmID, false)
	if err != "" {
		return err
	}

	// ! SEND TO WS
	wsPayload := map[string]any{
		"type":      "update_enabled",
		"device_id": data.DeviceID,
		"data": map[string]any{
			"alarm_id":   data.AlarmID,
			"is_enabled": false,
		},
	}

	jsonMsg, err3 := json.Marshal(wsPayload)
	if err3 != nil {
		return "Failed to enabled for broadcast."
	}

	log.Printf("WS > is enable > jsonMsg:%s\n", jsonMsg)
	config.Broadcast <- jsonMsg

	return ""
}
