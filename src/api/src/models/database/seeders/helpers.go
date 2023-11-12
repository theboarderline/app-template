package seeders

import (
	"fmt"
	"github.com/gocarina/gocsv"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/src/config"
	"os"
	"strings"
)

type FixtureTable interface {
	TableName() string
}

func getFixtures(table FixtureTable, fixtures *[]interface{}) error {
	file, err := openFixtureFile(table.TableName())
	if err != nil {
		log.Error().Err(err).Msgf("unable to open file %s", file.Name())
		return err
	}
	defer file.Close()

	if err = gocsv.UnmarshalFile(file, fixtures); err != nil {
		log.Error().Err(err).Msgf("unable to unmarshal file %s", file.Name())
		return err
	}

	return nil
}

func openFixtureFile(tableName string) (*os.File, error) {

	filePath := fmt.Sprintf("%s/src/models/database/fixtures/%s.csv", config.GetProjectRoot(), tableName)

	file, err := os.Open(filePath)
	if err != nil {
		log.Error().Err(err).Msgf("unable to open file %s", filePath)
		return nil, err
	}
	return file, nil
}

func cleanItem(item string) string {
	return strings.TrimSpace(item)
}
