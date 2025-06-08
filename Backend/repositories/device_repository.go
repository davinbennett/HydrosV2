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

func AddPlant(deviceID, plantName string, progressPlan int, latitude, longitude float64, location string) error {
	var device models.Device

	if err := config.PostgresDB.Where("id = ?", deviceID).First(&device).Error; err != nil {
		return err
	}

	device.PlantName = &plantName
	device.ProgressPlan = progressPlan
	device.Latitude = latitude
	device.Longitude = longitude
	device.Location = location
	
	return config.PostgresDB.Save(&device).Error
}

func GetPlantInfo(deviceID string) (string, int, int, error) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return "", 0.0, 0.0, err
	}
	return *device.PlantName, device.ProgressNow, device.ProgressPlan, nil
}

func UpdatePlant(deviceID string, plantName, location string, progressPlan int, latitude, longitude float64) error {
	var device models.Device

	if err := config.PostgresDB.Where("id = ?", deviceID).First(&device).Error; err != nil {
		return err
	}

	device.PlantName = &plantName
	device.ProgressPlan = progressPlan
	device.Latitude = latitude
	device.Longitude = longitude
	device.Location = location

	return config.PostgresDB.Save(&device).Error
}

func FindDeviceByCode(code string) (*models.Device, error) {
	var device models.Device
	if err := config.PostgresDB.Where("code = ?", code).First(&device).Error; err != nil {
		return nil, err
	}
	return &device, nil
}

// many2many pair
func AddDeviceToUser(userID, deviceID uint) error {
	var user models.User
	if err := config.PostgresDB.First(&user, userID).Error; err != nil {
		return err
	}

	var device models.Device
	if err := config.PostgresDB.First(&device, deviceID).Error; err != nil {
		return err
	}

	return config.PostgresDB.Model(&user).Association("Devices").Append(&device)
}

func UnpairDevice(userID uint, deviceID uint) error {
	var user models.User

	if err := config.PostgresDB.Preload("Devices").First(&user, userID).Error; err != nil {
		return err
	}

	// hapus relasi device dari user
	return config.PostgresDB.Model(&user).Association("Devices").Delete(&models.Device{ID: deviceID})
}
