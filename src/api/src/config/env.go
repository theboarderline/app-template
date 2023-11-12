package config

import (
	"github.com/joho/godotenv"
	"github.com/rs/zerolog/log"
	"os"
	"path/filepath"
)

var (
	RedisAddr = GetEnvOrReturn("REDIS_ADDR", "dragonfly-operator.dragonfly-system.svc:6379")
)

func LoadEnvVars() {
	envPath := filepath.Join(GetProjectRoot(), ".env")

	if err := godotenv.Load(envPath); err != nil {
		log.Warn().Msgf("No .env file loaded: %s", err)
	}
}

func GetLifecycle() string {
	lifecycle, ok := os.LookupEnv("LIFECYCLE")
	if !ok {
		lifecycle = "dev"
	}

	return lifecycle
}

func Init() {
	LoadEnvVars()
	GetLogger(GetLifecycle())
}
