package repositories

import (
	"main/config"
	"main/models"
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
		return "User not found"
	}

	user.Password = &hashedPassword
	if err := config.PostgresDB.Save(&user).Error; err != nil {
		return "Failed to update password"
	}

	return ""
}

