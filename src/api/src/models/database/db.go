package database

import (
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/models"
	"gorm.io/gorm"
)

func InitializeDatabase(dbVendor string) (db *gorm.DB, err error) {
	if db, err = getDatabaseConnection(dbVendor); err != nil {
		return nil, err
	}

	if err = RunMigrations(db); err != nil {
		return nil, err
	}

	if err = RunSeeds(db); err != nil {
		return nil, err
	}

	return db, nil
}

func RunMigrations(db *gorm.DB) (err error) {

	modelsList := []interface{}{
		&models.User{},
	}

	for _, model := range modelsList {
		if err = db.AutoMigrate(model); err != nil {
			log.Error().Err(err).Msgf("error migrating database table %s", model)
			return err
		}
	}

	return nil
}
