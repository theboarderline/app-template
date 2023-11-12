package database

import (
	"encoding/csv"
	"github.com/gocarina/gocsv"
	seeder "github.com/kachit/gorm-seeder"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/models/database/seeders"
	"gorm.io/gorm"
	"io"
)

func RunSeeds(db *gorm.DB) (err error) {

	seedersStack := seeder.NewSeedersStack(db)

	gocsv.SetCSVReader(func(in io.Reader) gocsv.CSVReader {
		r := csv.NewReader(in)
		r.Comma = '|'
		return r
	})

	// if model contains foreign key, must be seeded after the model it references
	dbSeeders := []seeder.SeederInterface{
		seeders.NewUsersSeeder(),
	}

	for _, s := range dbSeeders {
		seedersStack.AddSeeder(s)
	}

	if err = seedersStack.Seed(); err != nil {
		log.Error().Err(err).Msg("error importing seed data")
	}

	return nil
}
