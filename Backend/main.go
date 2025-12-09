package main

import (
	"log"
	"main/config"
	"main/infrastructure/cron"
	"main/infrastructure/mqtt"
	"main/infrastructure/websocket"
	"main/models"
	"main/repositories"
	"main/routes"
	"os"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-co-op/gocron/v2"
	"github.com/joho/godotenv"
)

func main() {
	if _, exists := os.LookupEnv("POSTGRES_HOST"); !exists {
        // Jika env tidak ada, run lokal, load .env
        if err := godotenv.Load(".env"); err != nil {
            log.Fatalf("🔴 Failed to load .env file: %v", err)
        } else {
            log.Println("✅ Loaded local .env file")
        }
    } else {
        log.Println("✅ Running in Docker, using environment variables from Compose")
    }

	if _, err := config.InitFirebase(); err != nil {
		log.Fatalf("❌ Firebase Init Failed: %v", err)
	}

	if err := config.ConnectRedis(); err != nil {
		log.Fatalf("🔴 Redis connection failed: %v", err)
	}

	if err := config.ConnectPostgres(); err != nil {
		log.Fatalf("🔴 Postgres connection failed: %v", err)
	}

	r := gin.Default()

	if err := config.AutoMigrate(
		&models.User{},
		&models.Alarm{},
		&models.Device{},
		&models.UserDevice{}, 
		&models.PumpLog{},
		&models.SensorAggregate{},
		&models.Fcm{},
		&models.Notification{},
	); err != nil {
		log.Fatalf("🔴 Migration failed: %v", err)
	}

	// ! CRON
	if err := config.InitCron(); err != nil {
		log.Fatalf("🔴 Init cron failed: %v", err)
	}
	_, err := config.CronScheduler.NewJob(
		gocron.DurationJob(10*time.Minute), // tiap 10 menit
		gocron.NewTask(cron.AggregateSensorData),
	)
	if err != nil {
		log.Fatal("🔴 Failed to schedule cron job:", err)
	}
	config.CronScheduler.Start()
	log.Println("✅ Cron started")

	// ! MQTT
	deviceIDs, errs := repositories.GetAllDeviceIDs()
	if errs != "" {
		log.Fatalf("🔴 Failed to get device IDs: %v", errs)
	}

	var wg sync.WaitGroup
	for _, deviceID := range deviceIDs {
		wg.Add(1)
		go func(did string) {
			defer wg.Done()
			client := config.InitMQTTClient(did)
			err := mqtt.SubscribeTopics(client, did)
			if err != "" {
				log.Fatalf("🔴 Failed to subscribe %s: %s", did, err)
			} 
		}(deviceID)
	}
	wg.Wait()

	// ! WEBSOCKET
	go websocket.StartBroadcaster()

	r.GET("/ws", func(c *gin.Context) {
		websocket.HandleWebSocket(c.Writer, c.Request)
	})

	// ! GEMINI
	go config.InitGemini()
	
	// ! RUN SERVER
	routes.InitRoutes(r)
	log.Println("✅ Server is Running in 8081")
	r.Run(":8081")
}
