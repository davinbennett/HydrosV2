package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func AlarmRoute(rg *gin.RouterGroup) {
	r := rg.Group("/alarm") 
	{
		r.GET("/:device-id", controllers.GetAlarmByDevice)

		r.POST("/:device-id", controllers.AddAlarm)
		r.DELETE("/:device-id", controllers.DeleteAlarm)
	}
}

