package config

import (
	"context"
	"log"
	"os"
	"sync"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

var (
	once     sync.Once
	app      *firebase.App
	client   *messaging.Client
	initErr  error
)

// InitFirebase hanya dijalankan 1x (singleton)
func InitFirebase() (*messaging.Client, error) {
	once.Do(func() {
		credPath := os.Getenv("FIREBASE_SERVICE_ACCOUNT")
		if credPath == "" {
			initErr =  ErrMissingFirebaseEnv()
			return
		}

		ctx := context.Background()
		opt := option.WithCredentialsFile(credPath)

		app, initErr = firebase.NewApp(ctx, nil, opt)
		if initErr != nil {
			return
		}

		client, initErr = app.Messaging(ctx)
		if initErr != nil {
			return
		}

		log.Println("✅ Firebase Admin initialized successfully")
	})

	return client, initErr
}

// Custom error
func ErrMissingFirebaseEnv() error {
	return  &MissingFirebaseEnvError{}
}

type MissingFirebaseEnvError struct{}

func (e *MissingFirebaseEnvError) Error() string {
	return "FIREBASE_SERVICE_ACCOUNT environment variable not set"
}