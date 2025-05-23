package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, APIResponse{
		Code: http.StatusOK,
		Data: data,
	})
}

func CreatedResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, APIResponse{
		Code: http.StatusCreated,
		Data: data,
	})
}

func UpdatedResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, APIResponse{
		Code:    http.StatusOK,
		Data:    data,
		Message: "Updated successfully",
	})
}

func DeletedResponse(c *gin.Context) {
	c.JSON(http.StatusOK, APIResponse{
		Code:    http.StatusOK,
		Message: "Deleted successfully",
	})
}

func BadRequestResponse(c *gin.Context, message string) {
	c.JSON(http.StatusBadRequest, APIResponse{
		Code:  http.StatusBadRequest,
		Error: message,
	})
}

func UnauthorizedResponse(c *gin.Context, message string) {
	c.JSON(http.StatusUnauthorized, APIResponse{
		Code:  http.StatusUnauthorized,
		Error: message,
	})
}

func ForbiddenResponse(c *gin.Context, message string) {
	c.JSON(http.StatusForbidden, APIResponse{
		Code:  http.StatusForbidden,
		Error: message,
	})
}

func NotFoundResponse(c *gin.Context, message string) {
	c.JSON(http.StatusNotFound, APIResponse{
		Code:  http.StatusNotFound,
		Error: message,
	})
}

func ConflictResponse(c *gin.Context, message string) {
	c.JSON(http.StatusConflict, APIResponse{
		Code:  http.StatusConflict,
		Error: message,
	})
}

func InternalServerErrorResponse(c *gin.Context, message string) {
	c.JSON(http.StatusInternalServerError, APIResponse{
		Code:  http.StatusInternalServerError,
		Error: message,
	})
}
