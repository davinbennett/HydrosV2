package controllers

import (
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)

func GetPumpUsage(c *gin.Context) {
	deviceID := c.Param("device-id")

	count, err := services.GetPumpUsageToday(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"pump_usage": count,
	})
}

func GetLastWatered(c *gin.Context) {
	deviceID := c.Param("device-id")

	lastWatered, err := services.GetLastWatered(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"last_watered": lastWatered,
	})
}

func GetPumpHistoryPreview(c *gin.Context) {
	deviceID := c.Param("device-id")

	logs, err := services.GetPumpStartTimes(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, logs)
}


func GetPumpLog(c *gin.Context) {
	deviceID := c.Param("device-id")
	today := c.DefaultQuery("today", "false") == "true"
	lastday := c.DefaultQuery("lastday", "false") == "true"
	month := c.DefaultQuery("month", "false") == "true"
	start := c.Query("start-date")
	end := c.Query("end-date")

	from, to, err := utils.ResolveDateRange(today, lastday, month, start, end)
	if err != nil {
		utils.BadRequestResponse(c, err.Error())
		return
	}

	result, errs := services.GetPumpLog(deviceID, from, to) // limit = 5
	if errs != "" {
		utils.InternalServerErrorResponse(c, errs)
		return
	}

	utils.SuccessResponse(c, result)
}

func DeletePumpLogByID(c *gin.Context) {
	id := c.Param("id")

	err := services.DeletePumpLog(id)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Success Delete Data")
}

func GetPumpQuickActivity(c *gin.Context) {
	deviceID := c.Param("device-id")

	today := c.DefaultQuery("today", "false") == "true"
	lastday := c.DefaultQuery("lastday", "false") == "true"
	month := c.DefaultQuery("month", "false") == "true"
	startDate := c.Query("start-date")
	endDate := c.Query("end-date")

	from, to, err := utils.ResolveDateRange(today, lastday, month, startDate, endDate)
	if err != nil {
		utils.BadRequestResponse(c, err.Error())
		return
	}

	data, errs := services.GetPumpQuickActivity(deviceID, from, to)
	if errs != "" {
		utils.InternalServerErrorResponse(c, errs)
		return
	}

	utils.SuccessResponse(c, data)
}
