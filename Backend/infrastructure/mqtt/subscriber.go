package mqtt

import (
	"encoding/json"
	"fmt"
	"log"
	"main/config"
	"main/models"
	"main/repositories"
	"strings"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func SubscribeTopics(client mqtt.Client, deviceID string) {
	topics := map[string]mqtt.MessageHandler{
		fmt.Sprintf("from-esp/%s/sensor", deviceID): handleSensorData,
		fmt.Sprintf("from-esp/%s/pump-status", deviceID): handlePumpStatus,
	}

	for topic, handler := range topics {
		if token := client.Subscribe(topic, 1, handler); token.Wait() && token.Error() != nil {
			log.Printf("[MQTT] Subscribe error: %v", token.Error())
		} else {
			log.Printf("[MQTT] Subscribed to topic: %s", topic)
		}
	}
}

func handleSensorData(client mqtt.Client, msg mqtt.Message) {
	topic := msg.Topic()
	payload := msg.Payload()

	deviceID := extractDeviceIDFromTopic(topic)
	log.Printf("[MQTT] Sensor data received | Device: %s | Topic: %s", deviceID, topic)

	var sensorData models.SensorData

	if err := json.Unmarshal(payload, &sensorData); err != nil {
		log.Printf("Failed to parse sensor data: %v", err)
		return
	}

	key := fmt.Sprintf("sensor/%s", deviceID)
	err := repositories.SaveSensorData(key, sensorData)
	if err != nil {
		log.Printf("Failed to save sensor data to Redis: %v", err)
	}

	// ! SEND TO WS
	wsPayload := map[string]interface{}{
		"type":      "sensor",
		"device_id": deviceID,
		"data":      sensorData,
	}
	jsonMsg, err := json.Marshal(wsPayload)
	if err != nil {
		log.Printf("Failed to marshal sensor WS payload: %v", err)
		return
	}
	config.Broadcast <- jsonMsg
}

func handlePumpStatus(client mqtt.Client, msg mqtt.Message) {
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
		log.Printf("Failed to marshal status WS payload: %v", err)
		return
	}
	config.Broadcast <- jsonMsg
}

func extractDeviceIDFromTopic(topic string) string {
	parts := strings.Split(topic, "/")
	if len(parts) >= 2 {
		return parts[1]
	}
	return "unknown deviceId"
}
