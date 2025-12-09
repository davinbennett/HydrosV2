package utils

func GetPumpControlSource(controlBy int) (titleSuffix string, description string) {
	switch controlBy {
	case 1:
		return "by Device", "Control was triggered directly by the device"
	case 2:
		return "by Manual Switch", "Control was triggered manually from the app"
	case 3:
		return "by Soil Sensor", "Control was triggered automatically by soil moisture"
	case 4:
		return "by Alarm", "Control was triggered automatically by schedule"
	default:
		return "by System", "Control was triggered by the system"
	}
}
