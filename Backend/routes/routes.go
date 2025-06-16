package routes

import (
	"main/middleware"

	"github.com/gin-gonic/gin"
)

func InitRoutes(r *gin.Engine) {
	route := r.Group("/api/v1")
	{
		AuthRoute(route)

		// ! SEMENTARA
		DeviceRoute(route)
		PumpLogRoute(route)
		AiRoutes(route)

		protected := route.Group("/")
		protected.Use(middleware.JWTMiddleware())
		{
			// DeviceRoute(protected)
		}
	}
}
