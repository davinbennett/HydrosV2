package repositories

import (
	"main/config"
	"main/models"

)

func GetAllDeviceIDs() ([]string, string) {
	var devices []models.Device
	err := config.PostgresDB.Select("id").Find(&devices).Error
	if err != nil {
		return nil, "Failed to get device IDs. Please try again later."
	}

	deviceIDs := make([]string, len(devices))
	for i, d := range devices {
		deviceIDs[i] = d.ID
	}

	return deviceIDs, ""
}

func UpdatePumpStatus(deviceID string, isOn bool) string {
	var device models.Device
	if err := config.PostgresDB.Where("id = ?", deviceID).First(&device).Error; err != nil {
		return "Device not found."
	}

	device.IsOn = isOn
	if err := config.PostgresDB.Save(&device).Error; err != nil {
		return "Failed to update pump status. Please try again."
	}
	return ""
}

func GetLocation(deviceID string) (string, string) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return "", "Device not found."
	}
	return device.Location, ""
}

func GetSoilSetting(deviceID string) (float64, float64, string) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return 0, 0, "Device not found."
	}
	return device.MinSoilSetting, device.MaxSoilSetting, ""
}

func GetCoords(deviceID string) (float64, float64, string) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return 0.0, 0.0, "Device not found."
	}
	return device.Longitude, device.Latitude, ""
}

func AddPlant(deviceID, plantName string, progressPlan int, latitude, longitude float64, location string) string {
	var device models.Device

	if err := config.PostgresDB.Where("id = ?", deviceID).First(&device).Error; err != nil {
		return "Device not found."
	}

	device.PlantName = &plantName
	device.ProgressPlan = progressPlan
	device.Latitude = latitude
	device.Longitude = longitude
	device.Location = location
	
	if err := config.PostgresDB.Save(&device).Error; err != nil {
		return "Failed to save plant information."
	}
	return ""
}

func GetPlantInfo(deviceID string) (string, int, int, string) {
	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return "", 0.0, 0.0, "Device not found."
	}
	if device.PlantName == nil {
		return "", device.ProgressNow, device.ProgressPlan, ""
	}
	return *device.PlantName, device.ProgressNow, device.ProgressPlan, ""
}

func UpdatePlant(deviceID string, plantName, location string, progressPlan int, latitude, longitude float64) string {
	var device models.Device

	if err := config.PostgresDB.Where("id = ?", deviceID).First(&device).Error; err != nil {
		return "Device not found."
	}

	device.PlantName = &plantName
	device.ProgressPlan = progressPlan
	device.Latitude = latitude
	device.Longitude = longitude
	device.Location = location

	if err := config.PostgresDB.Save(&device).Error; err != nil {
		return "Failed to update plant information."
	}
	return ""
}

func FindDeviceByCode(code string) (*models.Device, string) {
	var device models.Device
	if err := config.PostgresDB.Where("id = ?", code).First(&device).Error; err != nil {
		return nil, "Device not found with the provided code."
	}
	return &device, ""
}

// many2many pair
func AddDeviceToUser(userID uint, deviceID string) string {
	var user models.User
	if err := config.PostgresDB.First(&user, userID).Error; err != nil {
		return "User not found."
	}

	var device models.Device
	if err := config.PostgresDB.First(&device, "id = ?", deviceID).Error; err != nil {
		return "Device not found"
	}

	if err := config.PostgresDB.Model(&user).Association("Devices").Append(&device); err != nil {
		return "Failed to pair device with user."
	}
	return ""
}

func UnpairDevice(userID uint, deviceID string) string {
	var user models.User

	if err := config.PostgresDB.Preload("Devices").First(&user, userID).Error; err != nil {
		return "User not found."
	}

	if err := config.PostgresDB.Model(&user).Association("Devices").Delete(&models.Device{ID: deviceID}); err != nil {
		return "Failed to unpair device."
	}
	return ""
}

func UpdateSoilSettings(deviceID string, soilMin, soilMax float64) string {
	if err := config.PostgresDB.Model(&models.Device{}).
		Where("id = ?", deviceID).
		Updates(map[string]any{
			"min_soil_setting": soilMin,
			"max_soil_setting": soilMax,
		}).Error; err != nil {
		return "Failed to update soil settings."
	}
	return ""
}

func GetPumpStatusById(id string) (bool, string) {
	var device models.Device
	if err := config.PostgresDB.Where("id = ?", id).First(&device).Error; err != nil {
		return false, "Device not found with the provided id."
	}
	return device.IsOn, ""
}