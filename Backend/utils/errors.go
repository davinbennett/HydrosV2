package utils

import "errors"

var (
	ErrEmailNotRegistered = errors.New("email not registered")
	ErrLoginWithGoogle    = errors.New("this email is linked to a Google account")
	ErrInvalidPassword    = errors.New("incorrect email or password")
	ErrTokenGeneration    = errors.New("failed to generate token")
	ErrInvalidGoogleToken = errors.New("invalid Google ID token")
	ErrUserCreationFailed = errors.New("failed to create user")
	ErrUserNotFound       = errors.New("user not found")
)
