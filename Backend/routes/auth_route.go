package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func AuthRoute(rg *gin.RouterGroup) {
	auth := rg.Group("/auth") 
	{
		auth.POST("/login-google", controllers.LoginWithGoogle)
		// auth.POST("/login-google", controllers.LoginEmail)
	}
}
