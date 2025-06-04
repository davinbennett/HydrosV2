package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func DeviceRoute(rg *gin.RouterGroup) {
	r := rg.Group("/device") 
	{
		r.POST("/:id/pump-status", controllers.HandlePumpControl)
		
		r.GET("/:id/location", controllers.GetDeviceLocation)
		r.GET("/:id/weather-status", controllers.GetWeatherStatus)
	}
}
