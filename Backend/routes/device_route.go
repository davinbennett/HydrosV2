package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func DeviceRoute(rg *gin.RouterGroup) {
	r := rg.Group("/device") 
	{
		r.POST("/:id/control-switch", controllers.HandlePumpControl)
		r.POST("/:id/plant", controllers.AddPlant)
		r.POST("/:id/control-soil", controllers.HandleSoilControl)

		
		r.GET("/:id/location", controllers.GetDeviceLocation)
		r.GET("/:id/weather-status", controllers.GetWeatherStatus)
		r.GET("/:id/plant", controllers.GetPlantInfo)
		r.GET("/:id/pair", controllers.PairDevice)

		r.PATCH("/:id/plant", controllers.UpdatePlantInfo)

		r.DELETE("/:id/unpair", controllers.UnpairDevice)
	}
}
