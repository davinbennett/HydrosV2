package controllers

import (
	"main/dto"
	"main/services"
	"main/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)


func GenerateAIReport(c *gin.Context) {
	var req dto.AIReportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	result, err := services.GetAIReport(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	utils.SuccessResponse(c, result)
}