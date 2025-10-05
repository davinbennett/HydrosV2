package mqtt

import (
	"fmt"
	"log"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func PublishPumpControl(clients map[string]mqtt.Client, deviceID, command string) string {
	client, ok := clients[deviceID]
	if !ok {
		return fmt.Sprintf("No MQTT client found for device %s", deviceID)
	}

	topic := fmt.Sprintf("from-app/%s/handle-pump/from-switch", deviceID)
	token := client.Publish(topic, 1, false, command)
	token.Wait()

	if token.Error() != nil {
		log.Printf("[MQTT] Failed to publish pump command: %v", token.Error())
		return "Unable to send pump command. Please check your device connection."
	}
	
	log.Printf("[MQTT] Published pump control to %s: %s", topic, command)
	return ""
}

func PublishSoilControl(clients map[string]mqtt.Client, deviceID string, data string) string {
	client, ok := clients[deviceID]
	if !ok {
		return fmt.Sprintf("No MQTT client found for device %s", deviceID)
	}

	topic := fmt.Sprintf("from-app/%s/handle-pump/from-soil", deviceID)
	token := client.Publish(topic, 1, false, data)
	token.Wait()

	if token.Error() != nil {
		log.Printf("[MQTT] Failed to publish soil control: %v", token.Error())
		return "Unable to send soil control. Please check your device connection."
	}

	log.Printf("[MQTT] Published soil control to %s: %s", topic, string(data))
	return ""
}

func PublishAlarmControl(clients map[string]mqtt.Client, deviceID string, data string) string {
	client, ok := clients[deviceID]
	if !ok{
		return fmt.Sprintf("No MQTT client found for device %s", deviceID)
	}

	topic := fmt.Sprintf("from-app/%s/handle-pump/from-alarm", deviceID)
	token := client.Publish(topic, 1, false, data)
	token.Wait()

	if token.Error() != nil {
		log.Printf("[MQTT] Failed to publish alarm control: %v", token.Error())
		return "Unable to send alarm control. Please check your device connection."
	}

	log.Printf("[MQTT] Published alarm control to %s: %s", topic, string(data))
	return ""
}

func PublishEnabledAlarm(clients map[string]mqtt.Client, deviceID string, data string) string {
	client, ok := clients[deviceID]
	if !ok{
		return fmt.Sprintf("No MQTT client found for device %s", deviceID)
	}

	topic := fmt.Sprintf("from-app/%s/control-enabled-alarm", deviceID)
	token := client.Publish(topic, 1, false, data)
	token.Wait()

	if token.Error() != nil {
		log.Printf("[MQTT] Failed to publish alarm enabled: %v", token.Error())
		return "Unable to send alarm enabled. Please check your device connection."
	}

	log.Printf("[MQTT] Published alarm enabled to %s: %s", topic, string(data))
	return ""
}
