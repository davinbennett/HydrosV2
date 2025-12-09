package repositories

import (
	"main/config"
	"main/models"
)


func UpsertFcmToken(userID uint, deviceUID string, token string) string {
	var fcm models.Fcm

	// Cek apakah token untuk device ini sudah ada
	err := config.PostgresDB.
		Where("user_id = ? AND device_uid = ?", userID, deviceUID).
		First(&fcm).Error

	if err == nil {
		// Jika sudah ada → update token
		fcm.TokenID = token
		if err := config.PostgresDB.Save(&fcm).Error; err != nil {
			return "Failed to update FCM token"
		}
		return ""
	}

	// jika belum ada → insert baru
	newFcm := models.Fcm{
		UserID:    userID,
		DeviceUID: deviceUID,
		TokenID:   token,
	}

	if err := config.PostgresDB.Create(&newFcm).Error; err != nil {
		return "Failed to save FCM token"
	}

	return ""
}

// wkt logout & unpair
func DeleteFcmToken(userID uint, deviceUID string) string {
	if err := config.PostgresDB.
		Where("user_id = ? AND device_uid = ?", userID, deviceUID).
		Delete(&models.Fcm{}).Error; err != nil {
		return "Failed to delete FCM token"
	}

	return ""
}

// utk send notif ke fe
func GetUserFcmTokens(userID uint) ([]string, string) {
	var fcms []models.Fcm

	if err := config.PostgresDB.
		Where("user_id = ?", userID).
		Find(&fcms).Error; err != nil {
		return nil, "Failed to get FCM tokens"
	}

	var tokens []string
	for _, fcm := range fcms {
		tokens = append(tokens, fcm.TokenID)
	}

	return tokens, ""
}

func DeleteTokenByValue(token string) string {
	if err := config.PostgresDB.
		Where("token_id = ?", token).
		Delete(&models.Fcm{}).Error; err != nil {
		return "Failed to delete FCM token"
	}
	return ""
}
