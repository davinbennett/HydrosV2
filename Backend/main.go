package main

import (
    // "fmt"
    "github.com/gin-gonic/gin"
    "main/config"
    "log"
    "main/models"
    "main/routes"
)

func main() {
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