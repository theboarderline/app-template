package models

import (
	"fmt"
	"github.com/golang-jwt/jwt/v4"
	"github.com/rs/zerolog/log"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"math/rand"
	"os"
	"time"
)

const DefaultPasswordLength = 6

type User struct {
	gorm.Model
	ID             int    `json:"id" gorm:"primaryKey"`
	FirstName      string `json:"first_name" gorm:"not null"`
	LastName       string `json:"last_name" gorm:"not null"`
	Phone          string `json:"phone" gorm:"index"`
	Email          string `json:"email" gorm:"index"`
	Password       string `json:"password"`
	PhoneConfirmed bool   `json:"phone_confirmed" gorm:"default:false"`
	EmailConfirmed bool   `json:"email_confirmed" gorm:"default:false"`
	Role           string `json:"role"`

	PlainTextPassword string `json:"plain_text_password,omitempty" gorm:"-"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

func (u *User) TableName() string {
	return "users"
}

func (u *User) IsRole(roleName string) bool {
	return u.Role == roleName
}

func (u *User) GetFullName() string {
	return fmt.Sprintf("%s %s", u.FirstName, u.LastName)
}

func (u *User) PasswordMatches(password string) bool {
	if u.Password == "" {
		return false
	}

	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}

func (u *User) CreateAuthToken() (string, error) {
	var email string
	if u.Email != "" {
		email = u.Email
	}

	claims := jwt.MapClaims{
		"authorized": true,
		"user_id":    u.ID,
		"email":      email,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(os.Getenv("SECRET_KEY")))
}

func (u *User) ResetPassword() error {
	u.PlainTextPassword = GeneratePassword()
	hashedPassword, err := HashPassword(u.PlainTextPassword)
	if err != nil {
		log.Error().Err(err).Msg("Failed to hash password")
		return err
	}

	u.Password = hashedPassword

	return nil
}

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func GeneratePassword() string {
	return randSeq(DefaultPasswordLength)
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	return string(bytes), err
}
