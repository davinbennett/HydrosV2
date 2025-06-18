package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func PumpLogRoute(rg *gin.RouterGroup) {
	r := rg.Group("/pumplog") 
	{
		r.GET("/:device-id/pump-usage", controllers.GetPumpUsage)
		r.GET("/:device-id/last-watered", controllers.GetLastWatered)
		r.GET("/:device-id/history-preview", controllers.GetPumpHistoryPreview)
		r.GET("/:device-id", controllers.GetPumpLog)
		r.GET("/details/:device-id", controllers.GetPumpLogDetails)

		r.DELETE("/:id", controllers.DeletePumpLogByID)
	}
}
