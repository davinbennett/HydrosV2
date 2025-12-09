package models

import (
	"time"
)

type Fcm struct {
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"type:text;not null"`
	DeviceUID  string    `gorm:"type:text;not null"` // INI ID DARI HP > BUKAN ID DARI ESP
	TokenID   string    `gorm:"type:text;not null"`
	CreatedAt time.Time `gorm:"default:now()"`
	UpdatedAt time.Time `gorm:"default:now()"`

	User   User   `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}
