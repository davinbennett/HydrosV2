package repositories

import (
	"main/utils"
	"main/config"
	"main/models"
)

func GetUserByGoogleID(googleID string) (*models.User, error) {
	var user models.User
	if err := config.PostgresDB.Where("google_id = ?", googleID).First(&user).Error; err != nil {
		return nil, utils.ErrUserNotFound
	}
	return &user, nil
}

func CreateUser(user *models.User) error {
	return config.PostgresDB.Create(user).Error
}

func GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	if err := config.PostgresDB.Where("email = ?", email).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func UpdatePasswordByEmail(email, hashedPassword string) error {
	var user models.User
	if err := config.PostgresDB.Where("email = ?", email).First(&user).Error; err != nil {
		return err
	}

	user.Password = &hashedPassword
	return config.PostgresDB.Save(&user).Error
}
