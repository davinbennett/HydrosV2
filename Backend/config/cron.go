package config

import (
	"log"

	gocron "github.com/go-co-op/gocron/v2"
)

var CronScheduler gocron.Scheduler

func InitCron() error {
	scheduler, err := gocron.NewScheduler()
	if err != nil {
		log.Fatalf("Failed to start cron scheduler: %v", err)
	}

	CronScheduler = scheduler

	scheduler.Start()
	log.Println("Cron scheduler initialized")
	return nil
}