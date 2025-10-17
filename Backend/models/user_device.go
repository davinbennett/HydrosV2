package models

import "time"

type UserDevice struct {
	UserID    string    `gorm:"type:text;primaryKey"`
	DeviceID  string    `gorm:"type:text;primaryKey"`
	CreatedAt time.Time `gorm:"default:now()"`
	UpdatedAt time.Time `gorm:"default:now()"`
}
