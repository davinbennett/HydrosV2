package models

import "time"

type User struct {
	ID             uint `gorm:"primaryKey"`
	GoogleID       *string
	Devices        []Device `gorm:"many2many:user_devices;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	Name           *string
	Email          string
	Password       *string
	ProfilePicture *string
	CreatedAt      time.Time
	UpdatedAt      time.Time
}
