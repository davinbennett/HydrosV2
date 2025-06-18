package utils

import "strconv"

func ParseBoolParam(param string) bool {
	val, _ := strconv.ParseBool(param)
	return val
}
