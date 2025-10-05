package utils

// encode: Senin, Rabu, Jumat → 1, 3, 5
func EncodeRepeatDays(days []int) int {
	mask := 0
	for _, d := range days {
		mask |= 1 << (d - 1) // day 1=Senin … 7=Minggu
	}
	return mask
}

// decode: bitmask → slice hari
func DecodeRepeatDays(mask int) []int {
	days := []int{}
	for i := 0; i < 7; i++ {
		if mask&(1<<i) != 0 {
			days = append(days, i+1)
		}
	}
	return days
}
