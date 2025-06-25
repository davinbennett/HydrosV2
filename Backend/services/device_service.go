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

func AddPlantInfo(deviceID, plantName string, progressPlan int, lat, long float64, location string) error {
	return repositories.AddPlant(deviceID, plantName, progressPlan, lat, long, location)
}

func GetPlantInfo(deviceID string) (string, int, int, error) {
	plantName, progressNow, progressPlan, err := repositories.GetPlantInfo(deviceID)
	if err != nil {
		return "", 0, 0, err
	}

	return plantName, progressNow, progressPlan, nil
}

func UpdatePlant(deviceID string, plantName, location string, progressPlan int, latitude, longitude float64) error {
	return repositories.UpdatePlant(deviceID, plantName, location, progressPlan, latitude, longitude)
}

func PairDevice(userID uint, code string) (uint, error) {
	device, err := repositories.FindDeviceByCode(code)
	if err != nil {
		return 0, fmt.Errorf("device not found")
	}

	err = repositories.AddDeviceToUser(userID, device.ID)
	if err != nil {
		return 0, err
	}

	return device.ID, nil
}

func UnpairDevice(userID uint, deviceID uint) error {
	return repositories.UnpairDevice(userID, deviceID)
}

func ControlSoil(deviceID string, soilMin, soilMax int) error {
	return repositories.UpdateSoilSettings(deviceID, soilMin, soilMax)
}