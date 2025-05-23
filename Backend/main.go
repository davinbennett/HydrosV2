package main

import (
	// "fmt"
	"log"
	"main/config"
	"main/models"
	"main/routes"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
    if err := godotenv.Load(".env"); err != nil {
        log.Fatalf("Env connection failed: %v", err)
    }

    if err := config.ConnectRedis(); err != nil {
        log.Fatalf("Redis connection failed: %v", err)
    }

    if err := config.ConnectPostgres(); err != nil {
        log.Fatalf("Database connection failed: %v", err)
    }
    
    if err := config.AutoMigrate(&models.User{}, &models.Alarm{}, &models.Device{}, &models.PumpLog{}, &models.SensorAggregate{}, &models.SensorRaw{}); err != nil {
        log.Fatalf("Migration failed: %v", err)
    }

    r := gin.Default()

    routes.InitRoutes(r)

    r.Run(":8081")
}