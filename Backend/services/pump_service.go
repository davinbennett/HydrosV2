package services

import (
	"fmt"
	"main/repositories"
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

func GetPumpStartTimes(deviceID string) ([]map[string]interface{}, string) {
	return repositories.GetPumpStartTimes(deviceID)
}

func GetPumpLog(deviceID string, from, to *time.Time, limit int) (any, string) {
	logs, err := repositories.FindPumpLog(deviceID, from, to, limit)
	if err != "" {
		return nil, err
	}

	if len(logs) == 0 {
		return map[string]interface{}{
			"total_pump":       0,
			"average_duration": 0,
			"detail":           []any{},
		}, ""
	}

	totalDuration := 0
	details := make([]any, 0, len(logs))

	for _, log := range logs {
		// skip kalau start / end time null
		if log.StartTime == nil || log.EndTime == nil {
			continue
		}

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

	average := totalDuration / len(logs)

	return map[string]any{
		"total_pump":       len(logs),
		"average_duration": average,
		"detail":           details,
	}, ""
}

func GetPumpLogDetailList(deviceID string, from, to *time.Time) ([]map[string]interface{}, string) {
	logs, err := repositories.FindPumpLog(deviceID, from, to, 0) // 0 = no limit
	if err != "" {
		return nil, err
	}

	result := make([]map[string]interface{}, 0, len(logs))
	for _, log := range logs {
		duration := int(log.EndTime.Sub(*log.StartTime).Seconds())
		result = append(result, map[string]interface{}{
			"id":              log.ID,
			"triggered_by":    log.TriggeredBy,
			"start_time":      log.StartTime.Format(time.RFC3339),
			"end_time":        log.EndTime.Format(time.RFC3339),
			"time_difference": fmt.Sprintf("%ds", duration),
			"soil_before":     log.SoilBefore,
			"soil_after":      log.SoilAfter,
		})
	}

	return result, ""
}

func DeletePumpLog(id string) string {
	return repositories.DeletePumpLogByID(id)
}

func GetPumpQuickActivity(deviceID string, from, to *time.Time) (map[string]interface{}, string) {
	logs, err := repositories.FindPumpLog(deviceID, from, to, 1000)
	if err != "" {
		return nil, err
	}

	if len(logs) == 0 {
		return map[string]interface{}{
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

	return map[string]interface{}{
		"last_pumped": lastPumped.Format(time.RFC3339),
		"soil_min":    soilMin,
		"soil_max":    soilMax,
	}, ""
}
