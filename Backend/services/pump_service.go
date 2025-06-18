package services

import (
	"fmt"
	"main/repositories"
	"time"
)

func GetPumpUsageToday(deviceID string) (int64, error) {
	return repositories.GetTodayPumpUsage(deviceID)
}

func GetLastWatered(deviceID string) (*time.Time, error) {
	pumpLog, err := repositories.GetLastWateredTime(deviceID)
	if err != nil {
		return nil, err
	}

	return &pumpLog.UpdatedAt, nil
}

func GetPumpStartTimes(deviceID string) ([]map[string]interface{}, error) {
	return repositories.GetPumpStartTimes(deviceID)
}

func GetPumpLog(deviceID string, from, to *time.Time, limit int) (any, error) {
	logs, err := repositories.FindPumpLog(deviceID, from, to, limit)
	if err != nil {
		return nil, err
	}

	if len(logs) == 0 {
		return map[string]interface{}{
			"total_pump":       0,
			"average_duration": 0,
			"detail":           []any{},
		}, nil
	}

	totalDuration := 0
	details := make([]any, 0, len(logs))

	for _, log := range logs {
		duration := int(log.EndTime.Sub(*log.StartTime).Seconds())
		totalDuration += duration

		details = append(details, map[string]interface{}{
			"triggered_by":    log.TriggeredBy,
			"start_time":      log.StartTime.Format(time.RFC3339),
			"end_time":        log.EndTime.Format(time.RFC3339),
			"time_difference": fmt.Sprintf("%ds", duration),
			"soil_before":     log.SoilBefore,
			"soil_after":      log.SoilAfter,
		})
	}

	average := totalDuration / len(logs)

	return map[string]interface{}{
		"total_pump":       len(logs),
		"average_duration": average,
		"detail":           details,
	}, nil
}

func GetPumpLogDetailList(deviceID string, from, to *time.Time) ([]map[string]interface{}, error) {
	logs, err := repositories.FindPumpLog(deviceID, from, to, 0) // 0 = no limit
	if err != nil {
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

	return result, nil
}

func DeletePumpLog(id string) error {
	return repositories.DeletePumpLogByID(id)
}
