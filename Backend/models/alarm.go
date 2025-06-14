package models

import (
	"time"
)

type Alarm struct {
	ID           uint `gorm:"primaryKey"`
	DeviceID     uint
	IsExecute    bool `gorm:"default:false"`
	ScheduleTime *time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
