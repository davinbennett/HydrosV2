package controllers

import (
	"main/services"
	"main/utils"
	"github.com/gin-gonic/gin"
)

func GetPumpUsage(c *gin.Context) {
	deviceID := c.Param("device-id")

	count, err := services.GetPumpUsageToday(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to get pump usage")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"pump_usage": count,
	})
}

func GetLastWatered(c *gin.Context) {
	deviceID := c.Param("device-id")

	lastWatered, err := services.GetLastWatered(deviceID)
	if err != nil {
		utils.NotFoundResponse(c, "Pump log not found")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"last_watered": lastWatered,
	})
}

func GetPumpHistoryPreview(c *gin.Context) {
	deviceID := c.Param("device-id")

	logs, err := services.GetPumpStartTimes(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve pump history")
		return
	}

	utils.SuccessResponse(c, gin.H{"data": logs})
}
