package services

import (
	"main/infrastructure/gemini"
	"main/dto"
)

func GetAIReport(req dto.AIReportRequest) (map[string]any, string) {
	prompt := map[string]any{
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

// func GetAIReport(req dto.AIReportRequest) (map[string]interface{}, string) {

// 	mockData := map[string]interface{}{
// 		"plant_health_alert": "Severe drought stress detected; immediate intervention required.",
// 		"plant_health_desc": "The plant is currently suffering from extreme drought stress, with soil moisture at 0% just one hour after watering. This indicates either severe dehydration or a problem with water delivery/retention.",
// 		"plant_health_status": "Critical",
// 		"soil_ideal_range": "40-70%",
// 		"soil_ideal_range_desc": "Maintaining soil moisture between 40-70% ensures adequate hydration for root development and nutrient uptake.",
// 		"recommendation": []map[string]interface{}{
// 			{
// 				"title": "Immediate and Thorough Watering",
// 				"desc":  "Water the plant immediately and thoroughly until water drains from the root zone. Monitor soil moisture closely afterward.",
// 			},
// 			{
// 				"title": "Inspect Irrigation System and Soil Sensor",
// 				"desc":  "Verify pump operation and ensure water reaches the roots. Check soil moisture sensor placement and calibration.",
// 			},
// 			{
// 				"title": "Evaluate Soil Water Retention",
// 				"desc":  "Assess soil composition and improve water retention if the soil drains too quickly.",
// 			},
// 			{
// 				"title": "Monitor and Adjust Humidity",
// 				"desc":  "Increase ambient humidity if possible to reduce rapid water loss from the plant.",
// 			},
// 		},
// 	}

// 	return mockData, ""
// }
