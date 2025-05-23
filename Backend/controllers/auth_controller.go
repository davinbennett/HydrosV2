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
	if err != nil {
		switch err {
		case utils.ErrInvalidGoogleToken:
			utils.UnauthorizedResponse(c, "Google authentication failed.")
		case utils.ErrUserCreationFailed:
			utils.InternalServerErrorResponse(c, "Unable to create user.")
		case utils.ErrTokenGeneration:
			utils.InternalServerErrorResponse(c, "Token generation failed.")
		default:
			utils.InternalServerErrorResponse(c, "Something went wrong.")
		}
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
	if err != nil {
		switch err {
		case utils.ErrEmailNotRegistered, utils.ErrInvalidPassword:
			utils.UnauthorizedResponse(c, "Incorrect email or password.")
		case utils.ErrLoginWithGoogle:
			utils.UnauthorizedResponse(c, "This email is registered via Google. Please log in with Google.")
		default:
			utils.InternalServerErrorResponse(c, "Something went wrong. Please try again later.")
		}
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
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid email format.")
		return
	}

	if err := services.SendOTP(req.Email); err != nil {
		utils.InternalServerErrorResponse(c, "Failed to send OTP.")
		return
	}

	utils.SuccessResponse(c, gin.H{"message": "OTP sent to your email."})
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

	valid, errMsg := services.VerifyOTP(req.Email, req.OTP)
	if !valid {
		utils.UnauthorizedResponse(c, errMsg)
		return
	}

	utils.SuccessResponse(c, gin.H{"message": "OTP verified successfully."})
}

func RegisterWithEmail(c *gin.Context) {
	var req struct {
		Username string `json:"username" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=8"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequestResponse(c, "Invalid request format.")
		return
	}

	accessToken, userID, err := services.RegisterWithEmail(req.Username, req.Email, req.Password)
	if err != "" {
		utils.BadRequestResponse(c, err)
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
		utils.BadRequestResponse(c, "Invalid request format.")
		return
	}

	if err := services.ResetPassword(req.Email, req.NewPassword); err != nil {
		utils.UnauthorizedResponse(c, err.Error())
		return
	}

	utils.SuccessResponse(c, gin.H{
		"message": "Password reset successful. Please login again.",
	})
}
