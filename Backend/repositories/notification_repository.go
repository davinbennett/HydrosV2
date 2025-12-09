package repositories

import (
	"main/config"
	"main/models"
)

func CreateNotification(notif *models.Notification) (uint, string) {
	if err := config.PostgresDB.Create(&notif).Error; err != nil {
		return 0, "Failed to create notification"
	}
	return notif.ID, ""
}

func GetUserNotifications(userID uint) ([]models.Notification, string) {
	var notifs []models.Notification

	if err := config.PostgresDB.
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&notifs).Error; err != nil {
		return nil, "Failed to get notification"
	}

	return notifs, ""
}

func MarkNotificationRead(id uint) string {
	if err := config.PostgresDB.
		Model(&models.Notification{}).
		Where("id = ?", id).
		Update("is_read", true).Error; err != nil {
		return "Failed to marking notification"
	}

	return ""
}

func DeleteNotification(id uint) string {
	if err := config.PostgresDB.
		Delete(&models.Notification{}, id).Error; err != nil {
		return "Gagal menghapus notifikasi."
	}

	return ""
}
