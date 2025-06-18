package controllers

import (
	"main/services"
	"main/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func HandlePumpControl(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		IsOn bool `json:"ison"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	if err := services.ControlPump(deviceID, req.IsOn); err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	c.JSON(http.StatusOK, "Pump control sent")
}

func GetDeviceLocation(c *gin.Context) {
	deviceID := c.Param("id")

	loc, err := services.GetLocation(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
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
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"weather-status": status,
	})
}

func AddPlant(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		PlantName    string  `json:"plant_name"`
		ProgressPlan int     `json:"progress_plan"`
		Longitude    float64 `json:"longitude"`
		Latitude     float64 `json:"latitude"`
		Location     string  `json:"location"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	if err := services.AddPlantInfo(deviceID, req.PlantName, req.ProgressPlan, req.Latitude, req.Longitude, req.Location); err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, "Add plant success")
}

func GetPlantInfo(c *gin.Context) {
	deviceID := c.Param("id")

	plantName, progressNow, progressPlan, err := services.GetPlantInfo(deviceID)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"plant_name":    plantName,
		"progress_now":  progressNow,
		"progress_plan": progressPlan,
	})
}

func UpdatePlantInfo(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		PlantName    string  `json:"plant_name"`
		ProgressPlan int     `json:"progress_plan"`
		Longitude    float64 `json:"longitude"`
		Latitude     float64 `json:"latitude"`
		Location     string  `json:"location"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	err := services.UpdatePlant(deviceID, req.PlantName, req.Location, req.ProgressPlan, req.Latitude, req.Longitude)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.UpdatedResponse(c, gin.H{
		"plant_name":    req.PlantName,
		"progress_plan": req.ProgressPlan,
		"longitude":     req.Longitude,
		"latitude":      req.Latitude,
		"location":      req.Location,
	})
}

func PairDevice(c *gin.Context) {
	var req struct {
		Code string `json:"code"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request")
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "Unauthorized")
		return
	}

	deviceId, err := services.PairDevice(userID.(uint), req.Code)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	if deviceId == 0 {
		utils.NotFoundResponse(c, "Device code not found")
		return
	}

	utils.SuccessResponse(c, gin.H{
		"device_id": deviceId,
	})
}

func UnpairDevice(c *gin.Context) {
	deviceIDStr := c.Param("id")
	deviceID, err := strconv.ParseUint(deviceIDStr, 10, 64)
	if err != nil {
		utils.BadRequestResponse(c, "Invalid device ID")
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "Unauthorized")
		return
	}

	err = services.UnpairDevice(userID.(uint), uint(deviceID))
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, "Success Unpair")
}
