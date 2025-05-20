package models

import (
	"time"
)

type PumpLog struct {
	ID          uint `gorm:"primaryKey"`
	DeviceID    uint
	SoilBefore  float32 `gorm:"default:0.0"`
	SoilAfter   float32 `gorm:"default:0.0"`
	TriggeredBy *string // ! USER, ALARM, SOIL
	StartTime   *time.Time
	EndTime     *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
