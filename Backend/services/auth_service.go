package services

import (
	"context"
	"os"
	"strings"
	"time"

	"main/config"
	"main/models"
	"main/repositories"
	"main/utils"

	"google.golang.org/api/idtoken"
)

func ContinueWithGoogle(idToken string) (string, uint, string) {
	audience := os.Getenv("GOOGLE_CLIENT_ID")
	payload, err := idtoken.Validate(context.Background(), idToken, audience)
	if err != nil {
		return "", 0, "Something went wrong continue with Google."
	}

	email := payload.Claims["email"].(string)
	googleID := payload.Subject
	picture := payload.Claims["picture"].(string)
	name := payload.Claims["name"].(string)

	user, errStr := repositories.GetUserByGoogleID(googleID)
	if errStr != "" && errStr == "User not found." {
		// User not found, register new one
		user = &models.User{
			Email:          email,
			GoogleID:       &googleID,
			ProfilePicture: &picture,
			Name:           &name,
		}
		if err := repositories.CreateUser(user); err != "" {
			return "", 0, err
		}
	} else if errStr != "" {
		return "", 0, errStr
	}

	token, errStr := utils.GenerateJWT(user.ID, email)
	if errStr != "" {
		return "", 0, errStr
	}

	return token, user.ID, ""
}

func LoginWithEmail(email, password string) (string, uint, string) {
	user, err := repositories.GetUserByEmail(email)
	if err != "" {
		return "", 0, err
		
	}

	if user.Password == nil && user.GoogleID != nil {
		return "", 0, "This email can only be logged in with a Google account."
	}

	if user.Password == nil || !utils.CheckPasswordHash(password, *user.Password) {
		return "", 0, "Incorrect email or password."
	}

	token, err := utils.GenerateJWT(user.ID, email)
	if err != "" {
		return "", 0, err
	}

	return token, user.ID, ""
}


func SendOTP(email string) string {
	otp, _ := utils.GenerateOTP()
	hashedOTP, err := utils.HashPassword(otp)
	if err != nil {
		return "Failed to send OTP email"
	}

	key := "otp:" + strings.ToLower(email)

	err = config.RedisClient.HSet(config.RedisCtx, key, map[string]interface{}{
		"code":     hashedOTP,
		"verified": false,
	}).Err()
	if err != nil {
		return "Failed to send OTP email"
	}

	err = config.RedisClient.Expire(config.RedisCtx, key, 10*time.Minute).Err()
	if err != nil {
		return "Failed to send OTP email"
	}

	err = utils.SendOTPEmail(email, otp)
	if err != nil {
		return "Failed to send OTP email"
	}

	return ""
}


func VerifyOTP(email, otp string) (bool, string) {
	key := "otp:" + strings.ToLower(email)

	// Ambil semua field dari Redis (OTP hash dan status verifikasi)
	data, err := config.RedisClient.HGetAll(config.RedisCtx, key).Result()
	if err != nil || len(data) == 0 {
		return false, "OTP expired or not found."
	}

	storedOTP := data["code"]
	verified := data["verified"]

	if verified == "1" {
		return false, "OTP has already been verified."
	}

	// Cek apakah OTP cocok
	match := utils.CheckPasswordHash(otp, storedOTP)
	if !match {
		return false, "Incorrect OTP."
	}

	// Update status 'verified' jadi true
	err = config.RedisClient.HSet(config.RedisCtx, key, "verified", true).Err()
	if err != nil {
		return false, "Failed to update verification status."
	}

	return true, ""
}


func RegisterWithEmail(username, email, password string) (string, uint, string) {
	key := "otp:"+strings.ToLower(email)

	// Ambil field 'verified' dari Redis hash
	verified, err := config.RedisClient.HGet(config.RedisCtx, key, "verified").Result()
	if err != nil || verified != "1" {
		return "", 0, "Email has not been verified via OTP"
	}

	existingUser, errStr := repositories.GetUserByEmail(email)
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

	if err := repositories.CreateUser(user); err != "" {
		return "", 0, err
	}

	token, errStr := utils.GenerateJWT(user.ID, email)
	if errStr != "" {
		return "", 0, errStr
	}

	// delete redis
	config.RedisClient.Del(config.RedisCtx, key)

	return token, user.ID, ""
}

func ResetPassword(email, newPassword string) string {
	key := "otp:"+strings.ToLower(email)

	exists, err := config.RedisClient.Exists(config.RedisCtx, key).Result()
	if err != nil || exists == 0 {
		return "OTP verification required before resetting password"
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		return "Internal error while securing your password."
	}

	if err := repositories.UpdatePasswordByEmail(email, hashedPassword); err != "" {
		return err
	}

	config.RedisClient.Del(config.RedisCtx, key)
	return ""
}
