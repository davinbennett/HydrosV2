package models

import (
	"time"
)

type Alarm struct {
	ID           uint   `gorm:"primaryKey"`
	DeviceID     string `gorm:"type:text;not null"`
	IsExecute    bool   `gorm:"default:false"`
	ScheduleTime *time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time

	Device Device `gorm:"foreignKey:DeviceID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}
