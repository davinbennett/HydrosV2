package dto

type AIReportRequest struct {
	PlantName    string  `json:"plant_name"`
	ProgressPlan int     `json:"progress_plan"`
	ProgressNow  int     `json:"progress_now"`
	Longitude    string  `json:"longitude"`
	Latitude     string  `json:"latitude"`
	Temperature  float64 `json:"temperature"`
	Soil         float64 `json:"soil"`
	Humidity     float64 `json:"humidity"`
	PumpUsage    float64 `json:"pump_usage"`
	LastWatered  string  `json:"last_watered"`
	Datetime     string  `json:"datetime"`
}