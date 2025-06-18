package controllers

import (
	"main/services"
	"main/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetAggregatedSensorData(c *gin.Context) {
	deviceIDParam := c.Param("device-id")
	deviceID, err := strconv.Atoi(deviceIDParam)
	if err != nil {
		utils.BadRequestResponse(c, "Invalid device ID")
		return
	}

	today := c.DefaultQuery("today", "false") == "true"
	lastday := c.DefaultQuery("lastday", "false") == "true"
	month := c.DefaultQuery("month", "false") == "true"
	startDate := c.Query("start-date")
	endDate := c.Query("end-date")

	data, err := services.GetSensorAggregate(uint(deviceID), today, lastday, month, startDate, endDate)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, data)
}