package services

import (
	"encoding/json"
	"main/config"
	"main/infrastructure/mqtt"
	"main/infrastructure/weather"
	"main/repositories"
)

func ControlPumpSwitch(deviceID string, isOn bool) string {
	command := 2
	if isOn {
		command = 1
	}

	// Kirim format JSON ke MQTT
	payload := map[string]int{
		"status": command,
	}
	data, err := json.Marshal(payload)
	if err != nil {
		return "Failed to process command. Please try again."
	}

	// 1. Publish ke MQTT
	if err := mqtt.PublishPumpControl(config.MQTTClients, deviceID, string(data)); err != "" {
		return err
	}

	return ""
}

func ControlSoil(deviceID string, soilMin, soilMax float64) string {

	// Kirim format JSON ke MQTT
	payload := map[string]float64{
		"soil_min": soilMin,
		"soil_max": soilMax,
	}
	data, err := json.Marshal(payload)
	if err != nil {
		return "Failed to process command. Please try again."
	}

	// 1. Publish ke MQTT
	if err := mqtt.PublishSoilControl(config.MQTTClients, deviceID, string(data)); err != "" {
		return err
	}

	// 2. Update status soil di database
	if err := repositories.UpdateSoilSettings(deviceID, soilMin, soilMax); err != "" {
		return err
	}

	return ""
}


func GetLocation(deviceID string) (string, string) {
	return repositories.GetLocation(deviceID)
}

func GetSoilSetting(deviceID string) (float64, float64, string) {
	return repositories.GetSoilSetting(deviceID)
}

func GetWeatherStatus(deviceID string) (string, string) {
	long, lat, err := repositories.GetCoords(deviceID)
	if err != "" {
		return "", err
	}

	weatherStatus, err := weather.GetWeatherByCoords(long, lat)
	if err != "" {
		return "", err
	}

	return weatherStatus, ""
}

func AddPlantInfo(deviceID, plantName string, progressPlan int, lat, long float64, location string) string {
	return repositories.AddPlant(deviceID, plantName, progressPlan, lat, long, location)
}

func GetPlantInfo(deviceID string) (string, int, int, string) {
	plantName, progressNow, progressPlan, err := repositories.GetPlantInfo(deviceID)
	if err != "" {
		return "", 0, 0, err
	}

	return plantName, progressNow, progressPlan, ""
}

func UpdatePlant(deviceID string, plantName, location string, progressPlan int, latitude, longitude float64) string {
	return repositories.UpdatePlant(deviceID, plantName, location, progressPlan, latitude, longitude)
}

func PairDevice(userID uint, code string) (string, string) {
	device, err := repositories.FindDeviceByCode(code)
	if err != "" {
		return "", err
	}

	err = repositories.AddDeviceToUser(userID, code)
	if err != "" {
		return "", err
	}

	return device.ID, ""
}

func UnpairDevice(userID uint, deviceID string) string {
	return repositories.UnpairDevice(userID, deviceID)
}
