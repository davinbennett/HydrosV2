package utils

import (
	"fmt"
	"time"
)

func ResolveDateRange(today, lastday, month bool, start, end string) (*time.Time, *time.Time, error) {
	now := time.Now()
	loc := now.Location()
	var from, to time.Time

	// ddmmyy
	layout := "2006-01-02"

	// Helper untuk membuat 23:59:59
	makeEndOfDay := func(t time.Time) time.Time {
		return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 0, loc)
	}

	switch {
	case today:
		from = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
		to = makeEndOfDay(from)

	case lastday:
		y := now.AddDate(0, 0, -1)
		from = time.Date(y.Year(), y.Month(), y.Day(), 0, 0, 0, 0, loc)
		to = makeEndOfDay(from)

	case month:
		from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)
		lastDay := from.AddDate(0, 1, -1)
		to = makeEndOfDay(lastDay)

	case start != "" && end != "":
		s, err := time.ParseInLocation(layout, start, loc)
		if err != nil {
			return nil, nil, fmt.Errorf("invalid start-date format, expected ddmmyy")
		}
		e, err := time.ParseInLocation(layout, end, loc)
		if err != nil {
			return nil, nil, fmt.Errorf("invalid end-date format, expected ddmmyy")
		}

		// Normalisasi year dua digit -> 20xx
		if s.Year() < 100 {
			s = s.AddDate(2000, 0, 0)
		}
		if e.Year() < 100 {
			e = e.AddDate(2000, 0, 0)
		}

		from = time.Date(s.Year(), s.Month(), s.Day(), 0, 0, 0, 0, loc)
		to = makeEndOfDay(e)

	default:
		return nil, nil, nil
	}

	return &from, &to, nil
}
