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

func GetWeatherByCoords(lat, long float64) (string, string) {
	apiKey := os.Getenv("OWM_API_KEY")
	if apiKey == "" {
		return "", "Something went wrong. Please try again later."
	}

	url := fmt.Sprintf(
		"https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%s&units=metric&lang=en",
		lat, long, apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return "", "Failed to reach the weather service"
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", "Something went wrong. Please try again later."
	}

	var result WeatherAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", "Something went wrong. Please try again later."
	}

	if len(result.Weather) == 0 {
		return "", "Weather data is empty"
	}

	return result.Weather[0].Description, ""
}
