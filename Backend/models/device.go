package models

import (
	"time"
)

type Device struct {
	ID               string  `gorm:"type:text;primaryKey"`
	MinSoilSetting   float64 `gorm:"default:0.0"`
	MaxSoilSetting   float64 `gorm:"default:50.0"`
	IsOn             bool    `gorm:"default:false"`
	Latitude         float64 `gorm:"type:numeric(9,6);default:0.000000"`
	Longitude        float64 `gorm:"type:numeric(9,6);default:0.000000"`
	Location         string
	ProgressPlan     int `gorm:"default:0"`
	ProgressNow      int `gorm:"default:0"`
	PlantName        *string
	Users            []User `gorm:"many2many:user_devices;joinForeignKey:DeviceID;joinReferences:UserID"`
	PumpLogs         []PumpLog
	Alarms           []Alarm
	SensorAggregates []SensorAggregate
	CreatedAt        time.Time `gorm:"default:now()"`
	UpdatedAt        time.Time `gorm:"default:now()"`
}
