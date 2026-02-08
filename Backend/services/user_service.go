package services

import (
	"main/repositories"
)

func GetUserByID(userID string) (string, string, string, string) {
	user, err := repositories.GetUserByID(userID)
	if err != "" {
		return "", "", "", err
	}

	name := ""
	if user.Name != nil {
		name = *user.Name
	}

	profilePicture := ""
	if user.ProfilePicture != nil {
		profilePicture = *user.ProfilePicture
	}

	return name, user.Email, profilePicture, ""
}
