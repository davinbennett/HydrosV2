package repositories

import (
	"errors"
	"main/config"
	"main/models"
)

func GetUserByGoogleID(googleID string) (*models.User, error) {
	var user models.User
	if err := config.PostgresDB.Where("google_id = ?", googleID).First(&user).Error; err != nil {
		return nil, errors.New("user not found")
	}
	return &user, nil
}

func CreateUser(user *models.User) error {
	return config.PostgresDB.Create(user).Error
}
