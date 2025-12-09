package fcm

import (
	"context"
	"log"
	"main/config"
	"main/repositories"
	"time"

	"firebase.google.com/go/v4/messaging"
)

// ! FOKUS KE DB
func SaveFcmToken(userID uint, deviceUID string, token string) string {
	return repositories.UpsertFcmToken(userID, deviceUID, token)
}

func RemoveFcmToken(userID uint, deviceUID string) string {
	return repositories.DeleteFcmToken(userID, deviceUID)
}

func GetTokensByUser(userID uint) ([]string, string) {
	return repositories.GetUserFcmTokens(userID)
}


// ! FOKUS SEND KE FCM
const multicastBatchSize = 500
const fcmTimeout = 10 * time.Second

func SendFCMToUser(userID uint, title string, body string, data map[string]string) {
	tokens, errStr := repositories.GetUserFcmTokens(userID)
	if errStr != "" || len(tokens) == 0 {
		log.Printf("[FCM] no tokens for user %d: %s\n", userID, errStr)
		return
	}
	SendFCMToMany(tokens, title, body, data)
}

// SendFCMToMany: batching, send multicast, handle responses & cleanup invalid tokens
func SendFCMToMany(tokens []string, title, body string, data map[string]string) {
	if len(tokens) == 0 {
		return
	}

	client, err := config.InitFirebase()
	if err != nil {
		log.Println("[FCM] init error:", err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), fcmTimeout)
	defer cancel()

	// batch in chunks of 500 tokens (max supported by SendMulticast)
	for i := 0; i < len(tokens); i += multicastBatchSize {
		end := i + multicastBatchSize
		if end > len(tokens) {
			end = len(tokens)
		}
		batch := tokens[i:end]

		msg := &messaging.MulticastMessage{
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
			Data:   data,
			Tokens: batch,
			Android: &messaging.AndroidConfig{
				Priority: "high",
				Notification: &messaging.AndroidNotification{
					ClickAction: "FLUTTER_NOTIFICATION_CLICK",
				},
			},
			APNS: &messaging.APNSConfig{
				Headers: map[string]string{
					"apns-priority": "10",
				},
			},
		}

		br, err := client.SendEachForMulticast(ctx, msg)
		if err != nil {
			log.Println("[FCM] SendEachForMulticast error:", err)
			continue
		}

		log.Printf("[FCM] Sent multicast: success=%d failure=%d (batch size=%d)\n",
			br.SuccessCount, br.FailureCount, len(batch))

		// handle per-token responses -> hapus token yang invalid
		for idx, resp := range br.Responses {
			if !resp.Success {
				errStr := resp.Error
				token := batch[idx]
				log.Printf("[FCM] token failed idx=%d token=%s err=%v\n", idx, token, errStr)

				// common errors to cleanup: registration-token-not-registered,
				// invalid-registration-token, mismatch-sender-id, etc.
				// Simpan logic sederhana: hapus token jika error non-nil
				if errStr != nil {
					log.Printf("[FCM] removing invalid token: %s\n", token)
					if delErr := repositories.DeleteTokenByValue(token); delErr != "" {
						log.Printf("[FCM] failed to delete token %s: %s\n", token, delErr)
					}
				}
			}
		}
	}
}
