package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func SensorAggregateRoutes(rg *gin.RouterGroup) {
	r := rg.Group("/sensor-aggregated")
	{
		r.GET("/:device-id", controllers.GetAggregatedSensorData)
	}
}