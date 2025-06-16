package gemini

import (
	"context"
	"encoding/json"
	"fmt"
	"main/config"

	"google.golang.org/genai"
)

func GenerateReport(prompt map[string]interface{}) (map[string]interface{}, error){
	ctx := context.Background()

	model := "gemini-2.5-flash-preview-05-20"

	promptText := fmt.Sprintf(`
        Analyze the following plant irrigation and environmental data:
        - Plant name: %v
        - Planned progress stage: %v
        - Current growth progress: %v
        - Location (latitude, longitude): %v, %v
        - Temperature: %v°C
        - Humidity: %v%%
        - Soil moisture: %v%%
        - Pump usage duration: %v minutes
        - Last watered time: %v
        - Measurement timestamp: %v

        Based on this information, return a structured JSON response with the following:
        - soil_ideal_range: Ideal soil moisture range for the plant
        - soil_ideal_range_desc: Explanation of the soil moisture requirements
        - plant_health_status: Overall plant health status
        - plant_health_alert: Any alerts or warnings
        - plant_health_desc: Detailed description of current plant condition
        - recommendation: List of 3–5 suggestions for care (each with 'title' and 'desc')
        Format the response as valid JSON.
            `,
		prompt["plant_name"],
		prompt["progress_plan"],
		prompt["progress_now"],
		prompt["latitude"],
		prompt["longitude"],
		prompt["temperature"],
		prompt["humidity"],
		prompt["soil"],
		prompt["pump_usage"],
		prompt["last_watered"],
		prompt["datetime"],
	)

	configuration := &genai.GenerateContentConfig{
		ResponseMIMEType: "application/json",
		ResponseSchema: &genai.Schema{
			Type: genai.TypeObject,
			Properties: map[string]*genai.Schema{
				"soil_ideal_range":      {Type: genai.TypeString},
				"soil_ideal_range_desc": {Type: genai.TypeString},
				"plant_health_status":   {Type: genai.TypeString},
				"plant_health_alert":    {Type: genai.TypeString},
				"plant_health_desc":     {Type: genai.TypeString},
				"recommendation": {
					Type: genai.TypeArray,
					Items: &genai.Schema{
						Type: genai.TypeObject,
						Properties: map[string]*genai.Schema{
							"title": {Type: genai.TypeString},
							"desc":  {Type: genai.TypeString},
						},
						Required: []string{
							"title",
							"desc",
						},
						PropertyOrdering: []string{
							"title",
							"desc",
						},
					},
					MinItems: func() *int64 {
						i := int64(3)
						return &i
					}(),
					MaxItems: func() *int64 {
						i := int64(5)
						return &i
					}(),
				},
			},
			Required: []string{
				"soil_ideal_range",
				"soil_ideal_range_desc",
				"plant_health_status",
				"plant_health_alert",
				"plant_health_desc",
				"recommendation",
			},
			PropertyOrdering: []string{
				"soil_ideal_range",
				"soil_ideal_range_desc",
				"plant_health_status",
				"plant_health_alert",
				"plant_health_desc",
				"recommendation",
			},
		},
	}

	result, err := config.GeminiClient.Models.GenerateContent(
		ctx,
		model,
		genai.Text(promptText),
		configuration,
	)

	if err != nil {
		return nil, err
	}

	var parsed map[string]interface{}
	if err := json.Unmarshal([]byte(result.Text()), &parsed); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	return parsed, nil
}
