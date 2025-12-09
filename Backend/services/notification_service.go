package services

import (
	"main/models"
	"main/repositories"
)

func CreateNotification(userID uint, deviceID, title, body, notifType string) (uint, string) {
	notif := models.Notification{
		UserID:   userID,
		DeviceID: deviceID,
		Title:    title,
		Body:     body,
		Type:     notifType,
	}

	return repositories.CreateNotification(&notif)
}

func GetUserNotifications(userID uint) ([]models.Notification, string) {
	return repositories.GetUserNotifications(userID)
}

func ReadNotification(id uint) string {
	return repositories.MarkNotificationRead(id)
}

func DeleteNotification(id uint) string {
	return repositories.DeleteNotification(id)
}

