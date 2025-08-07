package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Code    int         `json:"code"`
	Data    any `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

func SuccessResponse(c *gin.Context, data any) {
	c.JSON(http.StatusOK, APIResponse{
		Code: 200,
		Data: data,
	})
}

func CreatedResponse(c *gin.Context, data any) {
	c.JSON(http.StatusCreated, APIResponse{
		Code: 200,
		Data: data,
	})
}

func UpdatedResponse(c *gin.Context, data any) {
	c.JSON(http.StatusOK, APIResponse{
		Code:    200,
		Data:    data,
		Message: "Updated successfully",
	})
}

func DeletedResponse(c *gin.Context) {
	c.JSON(http.StatusOK, APIResponse{
		Code:    200,
		Message: "Deleted successfully",
	})
}

func BadRequestResponse(c *gin.Context, message string) {
	c.JSON(http.StatusBadRequest, APIResponse{
		Code:  500,
		Message: message,
	})
}

func UnauthorizedResponse(c *gin.Context, message string) {
	c.JSON(http.StatusUnauthorized, APIResponse{
		Code:  500,
		Message: message,
	})
}

func ForbiddenResponse(c *gin.Context, message string) {
	c.JSON(http.StatusForbidden, APIResponse{
		Code:  500,
		Message: message,
	})
}

func NotFoundResponse(c *gin.Context, message string) {
	c.JSON(http.StatusNotFound, APIResponse{
		Code:  http.StatusNotFound,
		Message: message,
	})
}

func ConflictResponse(c *gin.Context, message string) {
	c.JSON(http.StatusConflict, APIResponse{
		Code:  500,
		Message: message,
	})
}

func InternalServerErrorResponse(c *gin.Context, message string) {
	c.JSON(http.StatusInternalServerError, APIResponse{
		Code:  500,
		Message: message,
	})
}
