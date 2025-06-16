package main

import (
	"fmt"
	"log"
	"main/config"
	"main/infrastructure/cron"
	"main/infrastructure/mqtt"
	"main/infrastructure/websocket"
	"main/models"
	"main/repositories"
	"main/routes"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-co-op/gocron/v2"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(".env"); err != nil {
		log.Fatalf("Env connection failed: %v", err)
	}

	// if err := config.ConnectRedis(); err != nil {
	// 	log.Fatalf("Redis connection failed: %v", err)
	// }

	if err := config.ConnectPostgres(); err != nil {
		log.Fatalf("Postgres connection failed: %v", err)
	}

	r := gin.Default()

	if err := config.AutoMigrate(
		&models.User{},
		&models.Alarm{},
		&models.Device{},
		&models.PumpLog{},
		&models.SensorAggregate{},
	); err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	// ! CRON
	if err := config.InitCron(); err != nil {
		log.Fatalf("Init cron failed: %v", err)
	}
	_, err := config.CronScheduler.NewJob(
		gocron.DurationJob(10*time.Minute), // tiap 10 menit
		gocron.NewTask(cron.AggregateSensorData),
	)
	if err != nil {
		log.Fatal("Failed to schedule cron job:", err)
	}
	config.CronScheduler.Start()
	log.Println("Cron started...")

	// ! MQTT
	config.InitMQTTClient()

	deviceIDsUint, err := repositories.GetAllDeviceIDs()
	if err != nil {
		log.Fatalf("Failed to get device IDs: %v", err)
	}

	var deviceIDs []string
	for _, id := range deviceIDsUint {
		deviceIDs = append(deviceIDs, fmt.Sprintf("DEVICE ID: %d", id))
	}

	var wg sync.WaitGroup
	for _, deviceID := range deviceIDs {
		wg.Add(1)
		go func(did string) {
			defer wg.Done()
			mqtt.SubscribeTopics(config.MQTTClient, did)
		}(deviceID)
	}
	wg.Wait()

	// ! WEBSOCKET
	go websocket.StartBroadcaster()

	r.GET("/ws", func(c *gin.Context) {
		websocket.HandleWebSocket(c.Writer, c.Request)
	})

	// ! GEMINI
	config.InitGemini()
	
	// ! RUN SERVER
	routes.InitRoutes(r)
	r.Run(":8081")
}
