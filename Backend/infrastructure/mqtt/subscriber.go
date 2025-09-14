package mqtt

import (
	"encoding/json"
	"fmt"
	"log"
	"main/config"
	"main/dto"
	"main/repositories"
	"strings"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func SubscribeTopics(client mqtt.Client, deviceID string) string {
	topics := map[string]mqtt.MessageHandler{
		fmt.Sprintf("from-esp/%s/sensor", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handleSensorData(c, m); err != "" {
				// kirim error ke log sederhana, tapi tetap return string error
				fmt.Printf("[MQTT] Sensor handler error: %s\n", err)
			}
		},
		fmt.Sprintf("from-esp/%s/pump-status", deviceID): func(c mqtt.Client, m mqtt.Message) {
			if err := handlePumpStatus(c, m); err != "" {
				fmt.Printf("[MQTT] Pump handler error: %s\n", err)
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

func handleSensorData(client mqtt.Client, msg mqtt.Message) string{
	topic := msg.Topic()
	payload := msg.Payload()

	deviceID := extractDeviceIDFromTopic(topic)
	log.Printf("[MQTT] Sensor data received | Device: %s | Topic: %s", deviceID, topic)

	var sensorData dto.SensorData

	if err := json.Unmarshal(payload, &sensorData); err != nil {
		return "Failed to save sensor data. Please try again later."
	}

	key := fmt.Sprintf("sensor/%s", deviceID)
	if err := repositories.SaveSensorData(key, sensorData); err != "" {
		return "Failed to save sensor data. Please try again later."
	}

	// ! SEND TO WS
	wsPayload := map[string]interface{}{
		"type":      "sensor",
		"device_id": deviceID,
		"data":      sensorData,
	}
	jsonMsg, err := json.Marshal(wsPayload)
	if err != nil {
		return "Failed to process sensor data for broadcast."
	}
	config.Broadcast <- jsonMsg
	return ""
}

func handlePumpStatus(client mqtt.Client, msg mqtt.Message) string {
	payload := string(msg.Payload())
	topic := msg.Topic()
	deviceID := extractDeviceIDFromTopic(topic)

	log.Printf("[MQTT] Pump status | Device: %s | Payload: %s", deviceID, payload)

	// ! SEND TO WS
	wsPayload := map[string]interface{}{
		"type":      "pump_status",
		"device_id": deviceID,
		"data": map[string]string{
			"status": payload,
		},
	}
	jsonMsg, err := json.Marshal(wsPayload)
	if err != nil {
		return "Failed to process pump status for broadcast."
	}
	config.Broadcast <- jsonMsg
	return ""
}

func extractDeviceIDFromTopic(topic string) string {
	parts := strings.Split(topic, "/")
	if len(parts) >= 2 {
		return parts[1]
	}
	return "Unknown."
}
