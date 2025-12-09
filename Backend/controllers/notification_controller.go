package controllers

import (
	"main/services"
	"main/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetMyNotifications(c *gin.Context) {
	userID := c.MustGet("user_id").(uint)

	data, err := services.GetUserNotifications(userID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, data)
}

// marking buat kl notif udh di read
func ReadNotification(c *gin.Context) {
	idParam := c.Param("id")
	id, _ := strconv.Atoi(idParam)

	err := services.ReadNotification(uint(id))
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Notifikasi telah dibaca.")
}

func DeleteNotification(c *gin.Context) {
	idParam := c.Param("id")
	id, _ := strconv.Atoi(idParam)

	err := services.DeleteNotification(uint(id))
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Notifikasi berhasil dihapus.")
}