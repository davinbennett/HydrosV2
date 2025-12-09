package models

import "time"

// ! many to many
type UserDevice struct {
	UserID    uint    `gorm:"type:text;primaryKey"`
	DeviceID  string    `gorm:"type:text;primaryKey"`
	CreatedAt time.Time `gorm:"default:now()"`
	UpdatedAt time.Time `gorm:"default:now()"`
}
