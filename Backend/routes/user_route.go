package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func UserRoute(rg *gin.RouterGroup) {
	r := rg.Group("/user") 
	{
		r.GET("/:id/", controllers.GetUserByID)
	}
}

