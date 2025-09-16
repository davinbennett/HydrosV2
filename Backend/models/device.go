package models

import (
	"time"
)

type Device struct {
	ID               string  `gorm:"type:text;primaryKey"`
	MinSoilSetting   float32 `gorm:"default:0.0"`
	MaxSoilSetting   float32 `gorm:"default:50.0"`
	IsOn             bool    `gorm:"default:false"`
	Latitude         float64 `gorm:"type:numeric(9,6);default:0.000000"`
	Longitude        float64 `gorm:"type:numeric(9,6);default:0.000000"`
	Location         string
	ProgressPlan     int `gorm:"default:0"`
	ProgressNow      int `gorm:"default:0"`
	Code             *string
	PlantName        *string
	IsActiveSoil     bool   `gorm:"default:false"`
	IsActivePump     bool   `gorm:"default:false"`
	Users            []User `gorm:"many2many:user_devices"`
	PumpLogs         []PumpLog
	Alarms           []Alarm
	SensorAggregates []SensorAggregate
	CreatedAt        time.Time
	UpdatedAt        time.Time
}
