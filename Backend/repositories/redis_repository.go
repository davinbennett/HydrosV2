package repositories

import (
	"context"
	"encoding/json"
	"main/config"
)

func SaveSensorData(key string, data any) string {
	client := config.RedisClient
	ctx := context.Background()

	jsonData, err := json.Marshal(data)
	if err != nil {
		return "Gagal menyimpan data sensor"
	}

	if err := client.RPush(ctx, key, jsonData).Err(); err != nil {
		return "Gagal menyimpan data sensor"
	}

	return ""
}

func GetSensorDataList(key string) ([]string, string) {
	ctx := context.Background()
	client := config.RedisClient

	result, err := client.LRange(ctx, key, 0, -1).Result()
	if err != nil {
		return nil, "Gagal mengambil data sensor"
	}

	return result, ""
}

func DeleteSensorData(key string) string {
	client := config.RedisClient
	ctx := context.Background()

	if err := client.Del(ctx, key).Err(); err != nil {
		return "Gagal menghapus data sensor"
	}

	return ""
}
