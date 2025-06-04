package repositories

import (
	"main/config"
	"main/models"
)

func GetAllDeviceIDs() ([]uint, error) {
	var devices []models.Device
	err := config.PostgresDB.Select("id").Find(&devices).Error
	if err != nil {
		return nil, err
	}

	deviceIDs := make([]uint, len(devices))
	for i, d := range devices {
		deviceIDs[i] = d.ID
	}

	return deviceIDs, nil
}

func UpdatePumpStatus(deviceID string, isOn bool) error {
	var device models.Device
	if err := config.PostgresDB.Where("device_id = ?", deviceID).First(&device).Error; err != nil {
		return err
	}

	device.IsOn = isOn
	return config.PostgresDB.Save(&device).Error
}

func GetLocation(deviceID string) (string, error) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return "", err
	}
	return device.Location, nil
}

func GetCoords(deviceID string) (float64, float64, error) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return 0.0, 0.0, err
	}
	return device.Longitude, device.Latitude, nil
}