package routes

import (
	"github.com/gin-gonic/gin"
)

func InitRoutes(r *gin.Engine) {
	route := r.Group("/api/v1")
	{
		AuthRoute(route)
	}
}
