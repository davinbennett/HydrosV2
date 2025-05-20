package models

import (
	"time"
)

type SensorRaw struct {
	ID           uint `gorm:"primaryKey"`
	DeviceID     uint
	Temperature  float32 `gorm:"default:0.0"`
	Humidity     float32 `gorm:"default:0.0"`
	SoilMoisture float32 `gorm:"default:0.0"`
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
