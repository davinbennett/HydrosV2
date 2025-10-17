package models

import "time"

type User struct {
	ID             uint `gorm:"primaryKey"`
	GoogleID       *string
	Devices        []Device `gorm:"many2many:user_devices;joinForeignKey:UserID;joinReferences:DeviceID"`
	Name           *string
	Email          string
	Password       *string
	ProfilePicture *string
	CreatedAt      time.Time `gorm:"default:now()"`
	UpdatedAt      time.Time `gorm:"default:now()"`
}
