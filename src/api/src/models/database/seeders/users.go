package seeders

import (
	"github.com/gocarina/gocsv"
	seeder "github.com/kachit/gorm-seeder"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/models"
	"gorm.io/gorm"
	"strconv"
)

type UsersSeeder struct {
	seeder.SeederAbstract
}

type UserFixture struct {
	ID        string `csv:"ID"`
	FirstName string `csv:"FIRST_NAME"`
	LastName  string `csv:"LAST_NAME"`
	Phone     string `csv:"PHONE"`
	Email     string `csv:"EMAIL"`
	Role      string `csv:"ROLE"`
	Password  string `csv:"PASSWORD"`
}

func NewUsersSeeder() *UsersSeeder {
	s := UsersSeeder{seeder.NewSeederAbstract(seeder.SeederConfiguration{})}
	return &s
}

func (s *UsersSeeder) Seed(db *gorm.DB) error {
	var fixtures []UserFixture
	var user models.User

	file, err := openFixtureFile(user.TableName())
	if err != nil {
		return err
	}
	defer file.Close()

	if err = gocsv.UnmarshalFile(file, &fixtures); err != nil {
		log.Error().Err(err).Msgf("unable to unmarshal file %s", file.Name())
		return err
	}

	for _, row := range fixtures {
		user = models.User{}

		id, err := strconv.Atoi(cleanItem(row.ID))
		if err != nil {
			log.Error().Err(err).Msgf("unable to convert ID %s to int", row.ID)
		}
		user.ID = id

		hashedPassword, err := models.HashPassword(cleanItem(row.Password))
		if err != nil {
			log.Error().Err(err).Msg("unable to hash password")
			return err
		}
		user.Password = hashedPassword

		user.Email = cleanItem(row.Email)
		user.Phone = cleanItem(row.Phone)
		user.FirstName = cleanItem(row.FirstName)
		user.LastName = cleanItem(row.LastName)
		user.Role = cleanItem(row.Role)

		if err = db.FirstOrCreate(&user).Error; err != nil {
			log.Error().Err(err).Msgf("unable to create user %v", user)
			return err
		}

		if db.RowsAffected != 0 {
			log.Info().Msgf("Created user: %s %s", user.FirstName, user.LastName)
		}

		user = models.User{}
	}

	return nil
}

func (s *UsersSeeder) Clear(db *gorm.DB) error {
	log.Debug().Msg("Clearing users table")
	var user models.User
	return s.SeederAbstract.Delete(db, user.TableName())
}
