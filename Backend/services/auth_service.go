package services

import (
	"context"
	"errors"
	"fmt"

	"main/repositories"
	"main/models"
	"main/utils"

	"google.golang.org/api/idtoken"
)

func LoginWithGoogle(idToken string) (string, uint, error) {
	payload, err := idtoken.Validate(context.Background(), idToken, "")
	if err != nil {
		return "", 0, errors.New("invalid Google ID token")
	}

	email := payload.Claims["email"].(string)
	googleID := payload.Subject
	picture := payload.Claims["picture"].(string)
	name := payload.Claims["name"].(string)

	user, err := repositories.GetUserByGoogleID(googleID)
	if err != nil {

		// not found, register
		user = &models.User{
			Email:          email,
			GoogleID:       &googleID,
			ProfilePicture: &picture,
			Name: &name,
		}
		if err := repositories.CreateUser(user); err != nil {
			return "", 0, err
		}
	}

	token, err := utils.GenerateJWT(user.ID, email)
	if err != nil {
		return "", 0, err
	}

	fmt.Println("\n\nJWT FROM BACKEND: ", token)

	return token, user.ID, nil
}
