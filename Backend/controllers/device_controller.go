package controllers

import (
	"main/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func HandlePumpControl(c *gin.Context) {
	deviceID := c.Param("id")

	var req struct {
		IsOn bool `json:"ison"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if err := services.ControlPump(deviceID, req.IsOn); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to control pump"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pump control sent"})
}
