package config

import (
	"context"
	"log"
	"os"

	"google.golang.org/genai"
)

var GeminiClient *genai.Client

func InitGemini() {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  os.Getenv("GEMINI_API"),
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		log.Fatalf("failed to initialize Gemini client: %v", err)
	}

	log.Println("✅ Gemini Connected")
	GeminiClient = client
}
