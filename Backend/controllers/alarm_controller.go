package controllers

import (
	"main/services"
	"main/utils"
	"github.com/gin-gonic/gin"
)

func GetAlarmByDevice(c *gin.Context) {
	deviceID := c.Param("device-id")

	data, err := services.GetDeviceAlarms(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong while fetching alarms.")
		return
	}

	utils.SuccessResponse(c, data)
}
