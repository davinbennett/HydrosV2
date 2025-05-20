package controllers

import (
	"main/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type GoogleLoginRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

func LoginWithGoogle(c *gin.Context) {
	var req GoogleLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	accessToken, userID, err := services.LoginWithGoogle(req.IDToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": http.StatusOK,
		"data": gin.H{
			"access_token": accessToken,
			"user_id":      userID,
		},
	})
}
