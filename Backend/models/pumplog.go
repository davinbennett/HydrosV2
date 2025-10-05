package models

import (
	"time"
)

type PumpLog struct {
	ID          uint    `gorm:"primaryKey"`
	DeviceID    string  `gorm:"type:text;not null"`
	SoilBefore  float64 `gorm:"default:0.0"`
	SoilAfter   float64 `gorm:"default:0.0"`
	TriggeredBy int     `gorm:"not null"` // 1: device, 2: switch, 3: soil, 4: alarm
	StartTime   *time.Time
	EndTime     *time.Time
	CreatedAt   time.Time `gorm:"default:now()"`
	UpdatedAt   time.Time `gorm:"default:now()"`

	Device Device `gorm:"foreignKey:DeviceID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}
