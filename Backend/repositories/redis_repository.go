package repositories

import (
	"context"
	"encoding/json"
	"main/config"
)

func SaveSensorData(key string, data any) error {
	client := config.RedisClient
	ctx := context.Background()

	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	return client.RPush(ctx, key, jsonData).Err()
}

func GetSensorDataList(key string) ([]string, error) {
	ctx := context.Background()
	client := config.RedisClient

	return client.LRange(ctx, key, 0, -1).Result()
}

func DeleteSensorData(key string) error {
	client := config.RedisClient
	ctx := context.Background()

	return client.Del(ctx, key).Err()
}