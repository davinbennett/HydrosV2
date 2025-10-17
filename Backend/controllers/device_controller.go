package controllers

import (
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)

func HandlePumpControl(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		IsOn bool `json:"ison"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input.")
		return
	}

	if err := services.ControlPumpSwitch(deviceID, req.IsOn); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Pump control sent.")
}

func GetDeviceLocation(c *gin.Context) {
	deviceID := c.Param("id")

	loc, err := services.GetLocation(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"location": loc,
	})
}

func GetWeatherStatus(c *gin.Context) {
	deviceID := c.Param("id")

	status, err := services.GetWeatherStatus(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
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

	if err := services.AddPlantInfo(deviceID, req.PlantName, req.ProgressPlan, req.Latitude, req.Longitude, req.Location); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Plant successfully added.")
}

func GetPlantInfo(c *gin.Context) {
	deviceID := c.Param("id")

	plantName, progressNow, progressPlan, err := services.GetPlantInfo(deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
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
		utils.BadRequestResponse(c, "Invalid input.")
		return
	}

	err := services.UpdatePlant(deviceID, req.PlantName, req.Location, req.ProgressPlan, req.Latitude, req.Longitude)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
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
		Code   string `json:"code"`
		UserID uint   `json:"user_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request.")
		return
	}


	deviceId, err := services.PairDevice(req.UserID, req.Code)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	if deviceId == "" {
		utils.NotFoundResponse(c, "Device code not found.")
		return
	}

	utils.SuccessResponse(c, "Success pair.")
}

func UnpairDevice(c *gin.Context) {
	deviceID := c.Param("id")

	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "Unauthorized.")
		return
	}

	err := services.UnpairDevice(userID.(uint), deviceID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Success Unpair.")
}

func HandleSoilControl(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		SoilMin float64 `json:"soil_min"`
		SoilMax float64 `json:"soil_max"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	if err := services.ControlSoil(deviceID, req.SoilMin, req.SoilMax); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Soil control updated.")
}
