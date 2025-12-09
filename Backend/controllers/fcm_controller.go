package controllers

import (
	"fmt"
	"main/infrastructure/fcm"
	"main/models"
	"main/repositories"
	"main/utils"

	"github.com/gin-gonic/gin"
)

func SaveFcmToken(c *gin.Context) {
	// ✅ SAFE AMBIL USER ID
	userIDRaw, exists := c.Get("user_id")
	if !exists {
		fmt.Println("CTX:", c.Keys)

		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	userID := userIDRaw.(uint)

	// ✅ BIND JSON KE STRUCT
	var req struct {
		Token     string `json:"token" binding:"required"`
		DeviceUID string `json:"device_uid" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request")
		return
	}

	// ✅ SIMPAN TOKEN
	if err := fcm.SaveFcmToken(userID, req.DeviceUID, req.Token); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "FCM token saved")
}


func DeleteFcmToken(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)
	deviceUID := c.Query("device_uid")

	if err := fcm.RemoveFcmToken(userID, deviceUID); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "FCM token deleted")
}

func TestSendFCMToUser(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)

	notif := models.Notification{
				UserID:   userID,
				DeviceID: "2497333B015C",
				Title:    "Pompa Menyala",
				Body:     "Pompa berhasil diaktifkan",
				Type:     "pump",
			}
	go repositories.CreateNotification(
		&notif,
	)

	fcm.SendFCMToUser(
		userID,
		"Test Notif Hydros ✅",
		"Ini notifikasi test langsung dari backend",
		map[string]string{
			"type": "test",
		},
	)

	utils.SuccessResponse(c, "Test FCM sent to user")
}

func TestSendFCMToToken(c *gin.Context) {
	var req struct {
		Token string `json:"token"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid payload")
		return
	}

	fcm.SendFCMToMany(
		[]string{req.Token},
		"Direct Token Test ✅",
		"Test langsung ke 1 token",
		map[string]string{
			"type": "direct",
		},
	)

	utils.SuccessResponse(c, "Test sent to token")
}

func TestSendSilentFCM(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)

	fcm.SendFCMToUser(
		userID,
		"", // kosong = silent
		"",
		map[string]string{
			"type": "silent",
			"route": "/home",
		},
	)

	utils.SuccessResponse(c, "Silent push sent")
}
