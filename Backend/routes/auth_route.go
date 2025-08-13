package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func AuthRoute(rg *gin.RouterGroup) {
	auth := rg.Group("/auth") 
	{
		auth.POST("/continue-google", controllers.ContinueWithGoogle)
		auth.POST("/login-email", controllers.LoginWithEmail)

				
		auth.POST("/request-otp", controllers.RequestOTP)
		auth.POST("/verify-otp", controllers.VerifyOTP)
		auth.POST("/register-email", controllers.RegisterWithEmail)

		auth.POST("/reset-password", controllers.ResetPassword)
	}
}
