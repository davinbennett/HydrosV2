package services

import (
	"main/repositories"
)


func GetUserByID(userID string) (string, string, string, string) {
	user, err := repositories.GetUserByID(userID)
	if err != "" {
		return "", "", "", err
	}

	return *user.Name, user.Email, *user.ProfilePicture, ""
}
