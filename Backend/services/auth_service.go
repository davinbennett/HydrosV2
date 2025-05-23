package services

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"main/config"
	"main/models"
	"main/repositories"
	"main/utils"

	"google.golang.org/api/idtoken"
)

func ContinueWithGoogle(idToken string) (string, uint, error) {
	payload, err := idtoken.Validate(context.Background(), idToken, "")
	if err != nil {
		return "", 0, utils.ErrInvalidGoogleToken
	}

	email := payload.Claims["email"].(string)
	googleID := payload.Subject
	picture := payload.Claims["picture"].(string)
	name := payload.Claims["name"].(string)

	user, err := repositories.GetUserByGoogleID(googleID)
	if err != nil && errors.Is(err, utils.ErrUserNotFound) {
		// User not found, register new one
		user = &models.User{
			Email:          email,
			GoogleID:       &googleID,
			ProfilePicture: &picture,
			Name:           &name,
		}
		if err := repositories.CreateUser(user); err != nil {
			return "", 0, utils.ErrUserCreationFailed
		}
	} else if err != nil {
		return "", 0, err
	}

	token, err := utils.GenerateJWT(user.ID, email)
	if err != nil {
		return "", 0, utils.ErrTokenGeneration
	}

	return token, user.ID, nil
}

func LoginWithEmail(email, password string) (string, uint, error) {
	user, err := repositories.GetUserByEmail(email)
	if err != nil {
		return "", 0, utils.ErrEmailNotRegistered
	}

	if user.Password == nil && user.GoogleID != nil {
		return "", 0, utils.ErrLoginWithGoogle
	}

	if user.Password == nil || !utils.CheckPasswordHash(password, *user.Password) {
		return "", 0, utils.ErrInvalidPassword
	}

	token, err := utils.GenerateJWT(user.ID, email)
	if err != nil {
		return "", 0, fmt.Errorf("%w: %v", utils.ErrTokenGeneration, err)
	}

	return token, user.ID, nil
}


func SendOTP(email string) error {
	otp, _ := utils.GenerateOTP()
	hashedOTP, e := utils.HashPassword(otp)
	if e != nil {
		return e
	}

	// save ke Redis 10 menit
	err := config.RedisClient.Set(config.RedisCtx, "otp:"+email, hashedOTP, 10*time.Minute).Err()
	if err != nil {
		return err
	}

	return utils.SendOTPEmail(email, otp)
}

func VerifyOTP(email, otp string) (bool, string) {
	key := "otp:" + strings.ToLower(email)

	storedOTP, err := config.RedisClient.Get(config.RedisCtx, key).Result()
	if err != nil {
		return false, "OTP expired or not found."
	}

	match := utils.CheckPasswordHash(otp, storedOTP)
	if !match {
		return false, "Incorrect OTP."
	}

	return true, ""
}

func RegisterWithEmail(username, email, password string) (string, uint, string) {
	key := "otp:"+strings.ToLower(email)

	verified, err := config.RedisClient.Get(config.RedisCtx, key).Result()
	if err != nil || verified == "" {
		return "", 0, "Email has not been verified via OTP"
	}

	existingUser, _ := repositories.GetUserByEmail(email)
	if existingUser != nil {
		if existingUser.GoogleID != nil {
			return "", 0, "Email is already registered with Google."
		}
		return "", 0, "Email is already registered."
	}

	hashedPassword, err := utils.HashPassword(password)
	if err != nil {
		return "", 0, "Internal error while securing your password."
	}

	user := &models.User{
		Email:    email,
		Name:     &username,
		Password: &hashedPassword,
	}

	if err := repositories.CreateUser(user); err != nil {
		return "", 0, "Failed to create user account."
	}

	token, err := utils.GenerateJWT(user.ID, email)
	if err != nil {
		return "", 0, "Failed to generate access token."
	}

	
	config.RedisClient.Del(config.RedisCtx, key)

	return token, user.ID, ""
}

func ResetPassword(email, newPassword string) error {
	key := "otp:"+strings.ToLower(email)

	exists, err := config.RedisClient.Exists(config.RedisCtx, key).Result()
	if err != nil || exists == 0 {
		return errors.New("OTP verification required before resetting password")
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		return errors.New("Failed to hash password")
	}

	if err := repositories.UpdatePasswordByEmail(email, hashedPassword); err != nil {
		return errors.New("Failed to reset password")
	}

	config.RedisClient.Del(config.RedisCtx, key)
	return nil
}
