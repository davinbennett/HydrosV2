package utils

import (
	"errors"
	"time"
)

func ResolveDateRange(today, lastday, month bool, start, end string) (*time.Time, *time.Time, error) {
	now := time.Now()
	var from, to time.Time
	layout := "020106"

	switch {
	case today:
		from = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		to = from.Add(24 * time.Hour)
	case lastday:
		yesterday := now.AddDate(0, 0, -1)
		from = time.Date(yesterday.Year(), yesterday.Month(), yesterday.Day(), 0, 0, 0, 0, now.Location())
		to = from.Add(24 * time.Hour)
	case month:
		from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
		to = from.AddDate(0, 1, 0)
	case start != "" && end != "":
		var err error
		from, err = time.Parse(layout, start)
		if err != nil {
			return nil, nil, errors.New("invalid start-date format, expected ddmmyy")
		}
		to, err = time.Parse(layout, end)
		if err != nil {
			return nil, nil, errors.New("invalid end-date format, expected ddmmyy")
		}
	default:
		return nil, nil, errors.New("no valid date range parameters provided")
	}

	return &from, &to, nil
}
