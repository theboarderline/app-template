package repository

import (
	"errors"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/models"
	"gorm.io/gorm"
)

type UserRepository interface {
	GetAll() ([]*models.User, error)
	GetByID(id int) (*models.User, error)
	GetByPhone(phone string) (*models.User, error)
	GetByEmail(email string) (*models.User, error)
	GetByEmailPassword(email, password string) (*models.User, error)

	Create(user models.User) (*models.User, error)
	Update(user models.User) (*models.User, error)
	Delete(id int) error
	ResetPassword(id int) (*models.User, error)
}

type userRepositoryImpl struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepositoryImpl{db: db}
}

func (u *userRepositoryImpl) Create(input models.User) (*models.User, error) {

	if input.FirstName == "" {
		log.Debug().Msg("User first name is required")
		return nil, errors.New("user first name is required")
	}

	if input.LastName == "" {
		log.Debug().Msg("User last name is required")
		return nil, errors.New("user last name is required")
	}

	var phone string
	if input.Phone != "" {
		phone = input.Phone
	}

	if input.Email != "" {
		var user models.User
		if _ = u.db.Where("email = ?", input.Email).Find(&user).Error; user.ID != 0 {
			return nil, errors.New("email already exists")
		}

	}

	user := models.User{
		FirstName:      input.FirstName,
		LastName:       input.LastName,
		Phone:          phone,
		Email:          input.Email,
		PhoneConfirmed: input.PhoneConfirmed,
		Password:       input.Password,
	}

	if user.Password != "" {
		password, err := models.HashPassword(user.Password)
		if err != nil {
			return nil, err
		}

		user.Password = password
	}

	user.Role = "user"

	if err := u.db.Create(&user).Error; err != nil {
		log.Error().Err(err).Msg("Failed to create user")
		return nil, err
	}

	log.Debug().Msgf("Created user: %d", user.ID)
	return &user, nil
}

func (u *userRepositoryImpl) Update(user models.User) (*models.User, error) {
	var userToUpdate models.User

	if err := u.db.First(&userToUpdate, user.ID).Error; err != nil {
		log.Error().Err(err).Msg("Failed to find user")
		return nil, err
	}

	if user.FirstName != "" {
		userToUpdate.FirstName = user.FirstName
	}

	if user.LastName != "" {
		userToUpdate.LastName = user.LastName
	}

	if user.Phone != "" {
		userToUpdate.Phone = user.Phone
	}

	if user.Email != "" {
		userToUpdate.Email = user.Email
	}

	if user.PhoneConfirmed != false {
		userToUpdate.PhoneConfirmed = user.PhoneConfirmed
	}

	if user.Password != "" {
		userToUpdate.Password = user.Password
	}

	if err := u.db.Save(&userToUpdate).Error; err != nil {
		log.Error().Err(err).Msg("Failed to update user")
		return nil, err
	}

	log.Debug().Msgf("Updated user: %d", userToUpdate.ID)
	return &userToUpdate, nil
}

func (u *userRepositoryImpl) Delete(id int) error {
	if err := u.db.Delete(&models.User{}, id).Error; err != nil {
		log.Error().Err(err).Msg("Failed to delete user")
		return err
	}

	log.Debug().Msgf("Deleted user: %d", id)
	return nil
}

func (u *userRepositoryImpl) GetAll() ([]*models.User, error) {
	var users []*models.User

	if err := u.db.
		Order("created_at desc").
		Find(&users).Error; err != nil {

		log.Debug().Err(err).Msg("Failed to get all users")
		return nil, err
	}

	log.Debug().Msgf("Found %d users", len(users))
	return users, nil
}

func (u *userRepositoryImpl) GetByID(id int) (*models.User, error) {
	var user models.User

	if err := u.db.First(&user, id).Error; err != nil {
		log.Debug().Err(err).Msgf("Failed to get user by id: %d", id)
		return nil, err
	}

	log.Debug().Msgf("Found user: %d", user.ID)
	return &user, nil
}

func (u *userRepositoryImpl) GetByPhone(phone string) (*models.User, error) {
	var user models.User

	if phone == "" {
		return nil, errors.New("phone is required")
	}

	if err := u.db.Where("phone = ?", phone).First(&user).Error; err != nil {

		log.Debug().Err(err).Msgf("Failed to get user by phone: %s", phone)
		return nil, err
	}

	log.Debug().Msgf("Found user: %d", user.ID)
	return &user, nil
}

func (u *userRepositoryImpl) GetByEmailPassword(email, password string) (user *models.User, err error) {

	if user, err = u.GetByEmail(email); err != nil {
		return nil, err
	}

	if password == "" {
		return nil, errors.New("password is required")
	} else if !user.PasswordMatches(password) {
		return nil, errors.New("email or password is invalid")
	}

	log.Debug().Msgf("Found user: %d", user.ID)
	return user, nil
}

func (u *userRepositoryImpl) GetByEmail(email string) (*models.User, error) {
	var user models.User

	if email == "" {
		return nil, errors.New("email is required")
	}

	if err := u.db.Where("email = ?", email).First(&user).Error; err != nil {
		log.Debug().Err(err).Msgf("Failed to get user by email: %s", email)
		return nil, err
	}

	log.Debug().Msgf("Found user: %d", user.ID)
	return &user, nil
}

func (u *userRepositoryImpl) ResetPassword(id int) (*models.User, error) {
	var user models.User

	if err := u.db.First(&user, id).Error; err != nil {
		log.Debug().Err(err).Msgf("Failed to get user by id: %d", id)
		return nil, err
	}

	if err := user.ResetPassword(); err != nil {
		return nil, err
	}

	if err := u.db.Save(&user).Error; err != nil {
		log.Error().Err(err).Msg("Failed to update user's password")
		return nil, err
	}

	log.Debug().Msgf("Reset password for user: %d", user.ID)
	return &user, nil
}
