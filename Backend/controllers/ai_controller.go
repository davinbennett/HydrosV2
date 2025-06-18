package controllers

import (
	"main/dto"
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)


func GenerateAIReport(c *gin.Context) {
	var req dto.AIReportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	result, err := services.GetAIReport(req)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Something went wrong, please try again later.")
		return
	}

	utils.SuccessResponse(c, result)
}