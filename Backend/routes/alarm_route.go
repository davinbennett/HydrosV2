package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func AlarmRoute(rg *gin.RouterGroup) {
	r := rg.Group("/alarm") 
	{
		r.GET("/:device-id", controllers.GetAlarmByDevice)

		r.POST("", controllers.AddAlarm)

		r.PATCH("/:id", controllers.UpdateAlarm)
		r.PATCH("/:id/control-enabled", controllers.UpdateEnabled)
		
		r.DELETE("/:id", controllers.DeleteAlarm)
	}
}

