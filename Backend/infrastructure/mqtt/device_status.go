package mqtt

import (
	"sync"
)

type DeviceStatus string

const (
	StatusDisconnected DeviceStatus = "disconnected"
	StatusUnstable     DeviceStatus = "unstable"
	StatusStable       DeviceStatus = "stable"
)

var (
	deviceStatusMap = make(map[string]DeviceStatus)
	statusMu        sync.RWMutex
)

func SetDeviceStatus(deviceID string, status DeviceStatus) {
	statusMu.Lock()
	defer statusMu.Unlock()
	deviceStatusMap[deviceID] = status
}

func GetDeviceStatus(deviceID string) DeviceStatus {
	statusMu.RLock()
	defer statusMu.RUnlock()
	return deviceStatusMap[deviceID]
}

func GetAllDeviceStatus() map[string]DeviceStatus {
	statusMu.RLock()
	defer statusMu.RUnlock()
	copyMap := make(map[string]DeviceStatus, len(deviceStatusMap))
	for k, v := range deviceStatusMap {
		copyMap[k] = v
	}
	return copyMap
}
