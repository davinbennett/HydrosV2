package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func NotificationRoutes(r *gin.RouterGroup) {
	notif := r.Group("/notifications") 
	{
		notif.GET("", controllers.GetMyNotifications)
		notif.PATCH("/:id/read", controllers.ReadNotification)
		notif.DELETE("/:id", controllers.DeleteNotification)
	}
}