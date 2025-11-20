package services

import (
	"fmt"
	"main/repositories"
	"math"
	"time"
)

func GetPumpUsageToday(deviceID string) (int64, string) {
	return repositories.GetTodayPumpUsage(deviceID)
}

func GetLastWatered(deviceID string) (*time.Time, string) {
	pumpLog, err := repositories.GetLastWateredTime(deviceID)
	if err != "" {
		return nil, err
	}

	return &pumpLog.UpdatedAt, ""
}

func GetPumpStartTimes(deviceID string) ([]map[string]any, string) {
	return repositories.GetPumpStartTimes(deviceID)
}

func GetPumpLog(deviceID string, from, to *time.Time) (any, string) {
	logs, err := repositories.FindPumpLog(deviceID, from, to)
	if err != "" {
		return nil, err
	}

	if len(logs) == 0 {
		return map[string]any{
			"total_pump":       0,
			"average_duration": 0,
			"detail":           []any{},
		}, ""
	}

	totalDuration := 0
	validCount := 0
	details := make([]any, 0, len(logs))

	for _, log := range logs {
		if log.StartTime == nil || log.EndTime == nil {
			continue
		}
		
		validCount++

		duration := int(log.EndTime.Sub(*log.StartTime).Seconds())
		totalDuration += duration

		details = append(details, map[string]any{
			"triggered_by":    log.TriggeredBy,
			"start_time":      log.StartTime.Format(time.RFC3339),
			"end_time":        log.EndTime.Format(time.RFC3339),
			"time_difference": fmt.Sprintf("%ds", duration),
			"soil_before":     log.SoilBefore,
			"soil_after":      log.SoilAfter,
		})
	}

	if validCount == 0 {
		return map[string]any{
			"total_pump":       0,
			"average_duration": 0.0,
			"detail":           details,
		}, ""
	}

	average := float64(totalDuration) / float64(validCount)

	average = math.Round(average*100) / 100

	return map[string]any{
		"total_pump":       validCount,
		"average_duration": average,
		"detail":           details,
	}, ""
}


func DeletePumpLog(id string) string {
	return repositories.DeletePumpLogByID(id)
}

func GetPumpQuickActivity(deviceID string, from, to *time.Time) (map[string]any, string) {
	logs, err := repositories.FindPumpLog(deviceID, from, to)
	if err != "" {
		return nil, err
	}

	if len(logs) == 0 {
		return map[string]any{
			"last_pumped": nil,
			"soil_min":    nil,
			"soil_max":    nil,
		}, ""
	}

	soilMin := logs[0].SoilBefore
	soilMax := logs[0].SoilBefore
	lastPumped := logs[0].StartTime

	for _, log := range logs {
		if log.SoilBefore < soilMin {
			soilMin = log.SoilBefore
		}
		if log.SoilBefore > soilMax {
			soilMax = log.SoilBefore
		}
		if log.StartTime.After(*lastPumped) {
			lastPumped = log.StartTime
		}
	}

	return map[string]any{
		"last_pumped": lastPumped.Format(time.RFC3339),
		"soil_min":    soilMin,
		"soil_max":    soilMax,
	}, ""
}
