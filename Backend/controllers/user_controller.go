package controllers

import (
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)

func GetUserByID(c *gin.Context) {
	userID := c.Param("id")

	username, email, profilePicture, err := services.GetUserByID(userID)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"username": username,
		"email": email, 
		"profile_picture": profilePicture,
	})
}