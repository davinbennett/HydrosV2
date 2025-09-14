package controllers

import (
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)

func GetAggregatedSensorData(c *gin.Context) {
	deviceID := c.Param("device-id")

	today := c.DefaultQuery("today", "false") == "true"
	lastday := c.DefaultQuery("lastday", "false") == "true"
	month := c.DefaultQuery("month", "false") == "true"
	startDate := c.Query("start-date")
	endDate := c.Query("end-date")

	data, err := services.GetSensorAggregate(deviceID, today, lastday, month, startDate, endDate)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, data)
}