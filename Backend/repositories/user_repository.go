package repositories

import (
	"main/config"
	"main/models"

	"gorm.io/gorm"
)

func GetUserByGoogleID(googleID string) (*models.User, string) {
	var user models.User
	if err := config.PostgresDB.Where("google_id = ?", googleID).First(&user).Error; err != nil {
		return nil, "User not found."
	}
	return &user, ""
}

func CreateUser(user *models.User) string {
	if err := config.PostgresDB.Create(user).Error; err != nil {
		return "Failed to create user."
	}
	return ""
}


func GetUserByEmail(email string) (*models.User, string) {
	var user models.User

	err := config.PostgresDB.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, "Enter your registered account."
	}

	return &user, ""
}

func UpdatePasswordByEmail(email, hashedPassword string) string {
	var user models.User
	if err := config.PostgresDB.Where("email = ?", email).First(&user).Error; err != nil {
		return "User not found."
	}

	user.Password = &hashedPassword
	if err := config.PostgresDB.Save(&user).Error; err != nil {
		return "Failed to update password."
	}

	return ""
}

func IsEmailExists(email string) (bool, string) {
	var user models.User
	err := config.PostgresDB.Where("email = ?", email).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return false, ""
		}
		return false, "Failed to check email."
	}

	// Kalau user ditemukan dan punya GoogleID
	if user.GoogleID != nil && *user.GoogleID != "" {
		return true, "This email is already registered as a Google account."
	}

	// Kalau user ditemukan tapi bukan Google account
	return true, "This email is already registered."
}

