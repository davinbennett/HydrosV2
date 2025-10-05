package config

import (
	"fmt"
	"log"
	"os"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var MQTTClients = make(map[string]mqtt.Client) // simpan banyak client

func InitMQTTClient(deviceID string) mqtt.Client {
	clientID := fmt.Sprintf("%s-%s", os.Getenv("MQTT_CLIENT_ID"), deviceID)
	
	opts := mqtt.NewClientOptions().
		AddBroker(os.Getenv("MQTT_BROKER")).
		SetClientID(clientID).
		SetCleanSession(true)

	client := mqtt.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		log.Fatalf("[MQTT] Connection error: %v", token.Error())
	}
	log.Println("✅ [MQTT] Connected to MQTT broker")

	MQTTClients[deviceID] = client
	return client
}
