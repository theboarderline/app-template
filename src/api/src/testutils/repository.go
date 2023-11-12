package testutils

import (
	. "github.com/onsi/gomega"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/models"
	"github.com/theboarderline/sample/api/src/models/database"
	"github.com/theboarderline/sample/api/src/repository"
	repoProviders "github.com/theboarderline/sample/api/src/repository/providers"
)

func GetTestRepository() *repository.Repository {
	db, err := database.InitializeDatabase("test")
	if err != nil {
		log.Fatal().Err(err).Msg("error initializing database")
	}

	repo, err := repoProviders.InitializeRepository(db)
	if err != nil {
		log.Fatal().Err(err).Msg("error initializing services")
	}

	return repo
}

func AssertUserEquals(actual *models.User, expected *models.User) {
	Expect(actual).NotTo(BeNil())
	Expect(actual.ID).To(BeEquivalentTo(expected.ID))
	Expect(actual.FirstName).To(BeEquivalentTo(expected.FirstName))
	Expect(actual.LastName).To(BeEquivalentTo(expected.LastName))
	Expect(actual.Phone).To(BeEquivalentTo(expected.Phone))
	Expect(actual.Email).To(BeEquivalentTo(expected.Email))
}
