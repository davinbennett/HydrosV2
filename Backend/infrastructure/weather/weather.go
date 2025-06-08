package weather

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

type WeatherAPIResponse struct {
	Weather []struct {
		Main        string `json:"main"`
		Description string `json:"description"`
	} `json:"weather"`
}

func GetWeatherByCoords(lat, long float64) (string, error) {
	apiKey := os.Getenv("OWM_API_KEY")
	if apiKey == "" {
		return "", fmt.Errorf("API key not found")
	}

	url := fmt.Sprintf(
		"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%s&units=metric&lang=en",
		lat, long, apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return "", nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", nil
	}

	var result WeatherAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", nil
	}

	if len(result.Weather) == 0 {
		return "", nil
	}

	return result.Weather[0].Description, nil
}
