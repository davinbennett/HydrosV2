package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func AiRoutes(rg *gin.RouterGroup) {
	ai := rg.Group("/ai")
	{
		ai.POST("/report", controllers.GenerateAIReport)
	}
}