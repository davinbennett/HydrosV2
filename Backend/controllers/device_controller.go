package controllers

import (
	"main/services"
	"main/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

func HandlePumpControl(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		IsOn bool `json:"ison"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if err := services.ControlPump(deviceID, req.IsOn); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to control pump"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pump control sent"})
}

func GetDeviceLocation(c *gin.Context) {
	deviceID := c.Param("id")

	loc, err := services.GetLocation(deviceID)
	if err != nil {
		utils.NotFoundResponse(c, "Device not found")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"location": loc,
	})
}

func GetWeatherStatus(c *gin.Context) {
	deviceID := c.Param("id")

	status, err := services.GetWeatherStatus(deviceID)
	if err != nil {
		utils.NotFoundResponse(c, "Failed to get weather status for device")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"weather-status": status,
	})
}