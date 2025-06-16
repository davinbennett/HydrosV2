package config

import (
	"log"
	"os"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var MQTTClient mqtt.Client 

func InitMQTTClient() mqtt.Client {
	opts := mqtt.NewClientOptions().
		AddBroker(os.Getenv("MQTT_BROKER")).
		SetClientID("hydros-backend-multi").
		SetCleanSession(true)

	client := mqtt.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		log.Fatalf("[MQTT] Connection error: %v", token.Error())
	}
	log.Println("✅ [MQTT] Connected to MQTT broker")

	MQTTClient = client
	return client
}
