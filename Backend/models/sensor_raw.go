package models

type SensorData struct {
	Temperature  float32 `json:"temperature"`
	Humidity     float32 `json:"humidity"`
	SoilMoisture float32 `json:"soil_moisture"`
}
