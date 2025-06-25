package controllers

import (
	"main/services"
	"main/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetPumpUsage(c *gin.Context) {
	deviceID := c.Param("device-id")

	count, err := services.GetPumpUsageToday(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
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
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
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
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
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
	limitStr := c.DefaultQuery("limit", "10")

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		utils.BadRequestResponse(c, "Invalid limit value")
		return
	}

	from, to, err := utils.ResolveDateRange(today, lastday, month, start, end)
	if err != nil {
		utils.BadRequestResponse(c, err.Error())
		return
	}

	result, err := services.GetPumpLog(deviceID, from, to, limit)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve pump log")
		return
	}

	utils.SuccessResponse(c, result)
}

func GetPumpLogDetails(c *gin.Context) {
	deviceID := c.Param("device-id")
	today := c.Query("today") == "true"
	lastday := c.Query("lastday") == "true"
	month := c.Query("month") == "true"
	start := c.Query("start-date")
	end := c.Query("end-date")

	from, to, err := utils.ResolveDateRange(today, lastday, month, start, end)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	data, err := services.GetPumpLogDetailList(deviceID, from, to)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, data)
}

func DeletePumpLogByID(c *gin.Context) {
	id := c.Param("id")

	err := services.DeletePumpLog(id)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
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

	data, err := services.GetPumpQuickActivity(deviceID, from, to)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, data)
}
