package models

import (
	"time"
)

type Alarm struct {
	ID           uint       `gorm:"primaryKey"`
	DeviceID     string     `gorm:"type:text;not null"`
	ScheduleTime *time.Time `gorm:"not null"`
	IsEnabled    bool       `gorm:"default:true"`
	DurationOn   int        `gorm:"default:5"` // in minutes

	RepeatType int `gorm:"type:int;default:1"` // 1=once,2=daily,3=weekly

	CreatedAt time.Time `gorm:"default:now()"`
	UpdatedAt time.Time `gorm:"default:now()"`

	Device Device `gorm:"foreignKey:DeviceID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}
