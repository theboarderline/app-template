package database

import (
	"fmt"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/config"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"math/rand"
	"os"
	"time"
)

const (
	MaxIdleConnections = 10
	MaxOpenConnections = 100
)

func createPath(path string) error {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		if err = os.MkdirAll(path, os.ModePerm); err != nil {
			log.Error().Err(err).Msgf("error creating directory %s", path)
			return err
		}
	}

	return nil
}

func getDatabaseConnection(dbVendor string) (*gorm.DB, error) {
	log.Info().Msgf("Connecting to %s database", dbVendor)

	var err error
	var db *gorm.DB

	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(getDatabaseLogLevel()),
	}

	if dbVendor == "postgres" {
		log.Info().Msg("USING POSTGRES DB")

		host, ok := os.LookupEnv("DB_HOST")
		if !ok {
			host = "127.0.0.1"
		}

		port, ok := os.LookupEnv("DB_PORT")
		if !ok {
			port = "5432"
		}

		// wait for cloud sql proxy to start
		time.Sleep(30 * time.Second)

		user := os.Getenv("DB_USER")
		dbname, ok := os.LookupEnv("DB_NAME")
		password := os.Getenv("DB_PASSWORD")

		log.Info().Msgf("host=%s port=%s user=%s dbname=%s", host, port, user, dbname)

		dbString := fmt.Sprintf("host=%s port=%s user=%s dbname=%s password=%s", host, port, user, dbname, password)

		db, err = gorm.Open(postgres.New(postgres.Config{
			DSN: dbString,
		}), gormConfig)
		if err != nil {
			log.Fatal().Err(err).Msg("error connecting to postgres db")
		}

		sqlDB, err := db.DB()
		if err != nil {
			log.Fatal().Err(err).Msg("error getting sql db")
		}
		sqlDB.SetMaxIdleConns(MaxIdleConnections)
		sqlDB.SetMaxOpenConns(MaxOpenConnections)
		sqlDB.SetConnMaxLifetime(time.Hour)

	} else {
		var dbLocation string
		if dbVendor == "memory" {
			log.Info().Msg("Using in-memory sqlite db")
			dbLocation = "file::memory:?cache=shared"
		} else {
			dbPath, ok := os.LookupEnv("DB_PATH")
			if !ok {
				dbPath = fmt.Sprintf("%s/%s", config.GetProjectRoot(), "var")
			}

			if err = createPath(dbPath); err != nil {
				log.Fatal().Err(err).Msg("unable to create db directory")
			}

			if dbVendor == "sqlite" {
				log.Info().Msg("Using file-based sqlite db")
				dbLocation = fmt.Sprintf("%s/db.sqlite", dbPath)
			} else {
				log.Info().Msg("Using random file-based sqlite db")
				dbLocation = fmt.Sprintf("%s/test-db-%d.sqlite", dbPath, rand.Int())
			}
		}

		db, err = gorm.Open(sqlite.Open(dbLocation), gormConfig)

		if sqliteDB, err := db.DB(); err != nil {
			log.Fatal().Err(err).Msg("failed to get DB from GORM")
		} else {
			sqliteDB.Exec("PRAGMA foreign_keys = ON;")
		}
	}

	return db, nil
}
