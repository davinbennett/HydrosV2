package mqtt

import (
	"fmt"
	"log"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func PublishPumpControl(client mqtt.Client, deviceID string, command string) error {
	topic := fmt.Sprintf("from-app/%s/handle-pump", deviceID)

	token := client.Publish(topic, 1, false, command)
	token.Wait()

	if token.Error() != nil {
		log.Printf("[MQTT] Failed to publish pump command: %v", token.Error())
		return token.Error()
	}
	log.Printf("[MQTT] Published pump control to %s: %s", topic, command)
	return nil
}
