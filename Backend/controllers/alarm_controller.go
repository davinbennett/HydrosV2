package controllers

import (
	"main/services"
	"main/utils"
	"time"

	"github.com/gin-gonic/gin"
)

func GetAlarmByDevice(c *gin.Context) {
	deviceID := c.Param("device-id")

	data, err := services.GetDeviceAlarms(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, data)
}

func AddAlarm(c *gin.Context) {

	var req struct {
		DeviceID string `json:"device_id" binding:"required"`
		ScheduleTime string `json:"schedule_time" binding:"required"`
		DurationOn   int    `json:"duration_on" binding:"required"`
		RepeatType   int    `json:"repeat_type" binding:"required"`
	}


	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request payload.")
		return
	}

	scheduleTime, err := time.Parse(time.RFC3339, req.ScheduleTime)
	if err != nil {
		utils.BadRequestResponse(c, "schedule_time must be in RFC3339 format (e.g., 2025-06-10T15:04:05Z).")
		return
	}

	if err := services.AddAlarm(req.DeviceID, scheduleTime, req.DurationOn, req.RepeatType); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Alarm added successfully.")
}

func UpdateAlarm(c *gin.Context) {
	alarmID := c.Param("id")

	var req struct {
		DeviceID string `json:"device_id" binding:"required"`
		ScheduleTime string `json:"schedule_time" binding:"required"`
		DurationOn   int    `json:"duration_on" binding:"required"`
		RepeatType   int    `json:"repeat_type" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}

	// parse schedule_time
	scheduleTime, err := time.Parse(time.RFC3339, req.ScheduleTime)
	if err != nil {
		utils.BadRequestResponse(c, "schedule_time must be in RFC3339 format (e.g., 2025-06-10T15:04:05Z).")
		return
	}

	if err := services.UpdateAlarm(req.DeviceID, alarmID, scheduleTime, req.DurationOn, req.RepeatType); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Alarm updated successfully.")
}


func DeleteAlarm(c *gin.Context) {
	alarmID := c.Param("id")

	var req struct {
		DeviceID string `json:"device_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}

	if err2 := services.DeleteAlarm(req.DeviceID, alarmID); err2 != "" {
		utils.InternalServerErrorResponse(c, err2)
		return
	}

	utils.SuccessResponse(c, "Alarm successfully deleted.")
}

func UpdateEnabled(c *gin.Context) {
	alarmID := c.Param("id")

	var req struct {
		DeviceID string `json:"device_id" binding:"required"`
		IsEnabled bool `json:"is_enabled"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}
	
	if err := services.UpdateEnabled(alarmID, req.IsEnabled, req.DeviceID); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Alarm enabled updated successfully.")
}