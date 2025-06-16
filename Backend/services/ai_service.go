package services

import (
	"main/infrastructure/gemini"
	"main/dto"
)

func GetAIReport(req dto.AIReportRequest) (map[string]interface{}, error) {
	prompt := map[string]interface{}{
		"plant_name":    req.PlantName,
		"progress_plan": req.ProgressPlan,
		"progress_now":  req.ProgressNow,
		"longitude":     req.Longitude,
		"latitude":      req.Latitude,
		"temperature":   req.Temperature,
		"soil":          req.Soil,
		"humidity":      req.Humidity,
		"pump_usage":    req.PumpUsage,
		"last_watered":  req.LastWatered,
		"datetime":      req.Datetime,
	}

	return gemini.GenerateReport(prompt)
}