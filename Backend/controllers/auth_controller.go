package controllers

import (
	"main/services"
	"main/utils"

	"github.com/gin-gonic/gin"
)


func ContinueWithGoogle(c *gin.Context) {
	var req struct {
		IDToken string `json:"id_token" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request format.")
		return
	}

	accessToken, userID, err := services.ContinueWithGoogle(req.IDToken)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"access_token": accessToken,
		"user_id":      userID,
	})
}


func LoginWithEmail(c *gin.Context) {
	var req struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Email and password must be filled in correctly.")
		return
	}

	accessToken, userID, err := services.LoginWithEmail(req.Email, req.Password)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"access_token": accessToken,
		"user_id":      userID,
	})
}


func RequestOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
		IsFrom string `json:"is_from" binding:"omitempty"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid email format.")
		return
	}

	isFrom := "default"
	if req.IsFrom != "" {
		isFrom = req.IsFrom
	}

	if err := services.SendOTP(req.Email, isFrom); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "OTP sent to your email.")
}


func VerifyOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required,len=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Email and OTP must be valid.")
		return
	}

	valid, err := services.VerifyOTP(req.Email, req.OTP)
	if !valid {
		utils.UnauthorizedResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"access_token": accessToken,
		"user_id":      userID,
	})
}

func RegisterWithEmail(c *gin.Context) {
	var req struct {
		Username string `json:"username" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=6,alphanum"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "")
		return
	}

	accessToken, userID, err := services.RegisterWithEmail(req.Username, req.Email, req.Password)
	if err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"access_token": accessToken,
		"user_id":      userID,
	})
}

func ResetPassword(c *gin.Context) {
	var req struct {
		Email       string `json:"email" binding:"required,email"`
		NewPassword string `json:"new_password" binding:"required,min=8"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid input")
		return
	}

	if err := services.ResetPassword(req.Email, req.NewPassword); err != "" {
		utils.InternalServerErrorResponse(c, err)
		return
	}

	utils.SuccessResponse(c, "Password reset successful. Please login again.")
}
