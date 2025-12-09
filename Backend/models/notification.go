package models

import (
	"time"
)

type Notification struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"not null;index"`
	DeviceID  string    `gorm:"not null;index"` // ESP32 ID
	Title     string    `gorm:"type:text;not null"`
	Body      string    `gorm:"type:text;not null"`
	Type      string    `gorm:"type:varchar(50);not null"` // alarm, soil, pump, ai
	IsRead    bool      `gorm:"default:false"`
	CreatedAt time.Time `gorm:"autoCreateTime"`

	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Device Device `gorm:"foreignKey:DeviceID;constraint:OnDelete:CASCADE"`
}
