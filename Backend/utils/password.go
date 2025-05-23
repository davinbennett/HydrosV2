package utils

import (
	"golang.org/x/crypto/bcrypt"
	"regexp"
)

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func IsValidPassword(password string) bool {
	if len(password) < 8 {
		return false
	}
	matched, _ := regexp.MatchString(`[0-9]`, password)
	return matched
}