package models

import (
	"time"
)

type SensorAggregate struct {
	ID              uint `gorm:"primaryKey"`
	DeviceID        string `gorm:"type:text;not null"`
	AvgTemperature  float32 `gorm:"default:0.0"`
	AvgHumidity     float32 `gorm:"default:0.0"`
	AvgSoilMoisture float32 `gorm:"default:0.0"`
	IntervalStart   *time.Time // waktu cron dijalankan - 10 menit
	IntervalEnd     *time.Time // waktu cron dijalankan
	CreatedAt       time.Time
	UpdatedAt       time.Time

	Device Device `gorm:"foreignKey:DeviceID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}
