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
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong while fetching alarms.")
		return
	}

	utils.SuccessResponse(c, data)
}

func AddAlarm(c *gin.Context) {
	deviceID := c.Param("device-id")

	var req struct {
		ScheduleTime string `json:"schedule_time" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "schedule_time is required.")
		return
	}

	scheduleTime, err := time.Parse(time.RFC3339, req.ScheduleTime)
	if err != nil {
		utils.BadRequestResponse(c, "schedule_time must be in RFC3339 format (e.g., 2025-06-10T15:04:05Z).")
		return
	}

	if err := services.AddAlarm(deviceID, scheduleTime); err != nil {
		utils.InternalServerErrorResponse(c, "Failed to create alarm.")
		return
	}

	utils.SuccessResponse(c, nil)
}

func DeleteAlarm(c *gin.Context) {
	deviceID := c.Param("device-id")

	var req struct {
		ScheduleTime string `json:"schedule_time" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "schedule_time is required.")
		return
	}

	scheduleTime, err := time.Parse(time.RFC3339, req.ScheduleTime)
	if err != nil {
		utils.BadRequestResponse(c, "schedule_time must be in RFC3339 format (e.g., 2025-06-10T17:00:00Z).")
		return
	}

	if err := services.DeleteAlarm(deviceID, scheduleTime); err != nil {
		utils.InternalServerErrorResponse(c, "Failed to delete alarm.")
		return
	}

	utils.SuccessResponse(c, nil)
}