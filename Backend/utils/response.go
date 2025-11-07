package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type APIResponse struct {
	Code    int         `json:"code"`
	Data    any         `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

func jsonResponse(c *gin.Context, status int, data any, message string) {
	c.JSON(status, APIResponse{
		Code:    status,
		Data:    data,
		Message: message,
	})
}

func SuccessResponse(c *gin.Context, data any) {
	jsonResponse(c, http.StatusOK, data, "")
}

func CreatedResponse(c *gin.Context, data any) {
	jsonResponse(c, http.StatusCreated, data, "")
}

func UpdatedResponse(c *gin.Context, data any) {
	jsonResponse(c, http.StatusOK, data, "Updated successfully")
}

func DeletedResponse(c *gin.Context) {
	jsonResponse(c, http.StatusOK, nil, "Deleted successfully")
}

func BadRequestResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusBadRequest, nil, message)
}

func UnauthorizedResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusUnauthorized, nil, message)
}

func ForbiddenResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusForbidden, nil, message)
}

func NotFoundResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusNotFound, nil, message)
}

func ConflictResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusConflict, nil, message)
}

func InternalServerErrorResponse(c *gin.Context, message string) {
	jsonResponse(c, http.StatusInternalServerError, nil, message)
}
