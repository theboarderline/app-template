package database

import (
	"github.com/theboarderline/sample/api/src/config"
	"gorm.io/gorm/logger"
)

func getDatabaseLogLevel() logger.LogLevel {
	lifecycle := config.GetLifecycle()
	var logLevel logger.LogLevel

	if lifecycle == "prod" {
		logLevel = logger.Info
	} else {
		logLevel = logger.Warn
	}

	return logLevel
}
