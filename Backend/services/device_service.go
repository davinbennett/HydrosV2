package services

import (
	"encoding/json"
	"fmt"
	"main/config"
	"main/infrastructure/mqtt"
	"main/infrastructure/weather"
	"main/repositories"
)

func ControlPump(deviceID string, isOn bool) error {
	command := "off"
	if isOn {
		command = "on"
	}

	// Kirim format JSON ke MQTT
	payload := map[string]string{
		"status": command,
	}
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	// 1. Publish ke MQTT
	if err := mqtt.PublishPumpControl(config.MQTTClient, deviceID, string(data)); err != nil {
		return err
	}

	// 2. Update status pompa di database
	if err := repositories.UpdatePumpStatus(deviceID, isOn); err != nil {
		return fmt.Errorf("failed to update device status: %w", err)
	}

	return nil
}

func GetLocation(deviceID string) (string, error) {
	return repositories.GetLocation(deviceID)
}

func GetWeatherStatus(deviceID string) (string, error) {
	long, lat, err := repositories.GetCoords(deviceID)
	if err != nil {
		return "", err
	}

	weatherStatus, err := weather.GetWeatherByCoords(long, lat)
	if err != nil {
		return "", err
	}

	return weatherStatus, nil
}
