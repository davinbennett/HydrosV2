package routes

import (
	"main/controllers"

	"github.com/gin-gonic/gin"
)

func FcmRoute(rg *gin.RouterGroup) {
	r := rg.Group("/fcm") 
	{
		r.POST("", controllers.SaveFcmToken)
		r.DELETE("", controllers.DeleteFcmToken)

		// TESTING NOTIF
		r.POST("/fcm-user", controllers.TestSendFCMToUser)
		r.POST("/fcm-token", controllers.TestSendFCMToToken)
		r.POST("/fcm-silent", controllers.TestSendSilentFCM)
	}
}
