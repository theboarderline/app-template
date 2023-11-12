package engine

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/theboarderline/sample/api/docs"
	"github.com/theboarderline/sample/api/src/config"
	"github.com/theboarderline/sample/api/src/models/database"
	repoProviders "github.com/theboarderline/sample/api/src/repository/providers"
	"github.com/theboarderline/sample/api/src/server/urls"
	"os"
)

const defaultPort = "8000"

func init() {
	config.Init()
}

func GetEngine(logger *zerolog.Logger, customCtx *config.CustomContext) *gin.Engine {
	lifecycle := os.Getenv("LIFECYCLE")
	if lifecycle == "prod" {
		gin.SetMode(gin.ReleaseMode)
	}

	engine := gin.New()

	if err := engine.SetTrustedProxies(nil); err != nil {
		log.Warn().Err(err).Msg("Error setting trusted proxies")
	}

	engine.Use(gin.Recovery())

	engine.Use(config.CustomContextMiddleware(customCtx))
	engine.Use(config.LoggingMiddleware(logger))

	urls.AddRoutes(engine)

	docs.SwaggerInfo.BasePath = "/api"

	return engine
}

func GetPort() string {
	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = defaultPort
	}

	return port
}

func Run() {

	logger := config.GetLogger(config.GetLifecycle())

	db, err := database.InitializeDatabase(os.Getenv("DB_VENDOR"))
	if err != nil {
		log.Fatal().Err(err).Msg("Unable to seed database")
	}

	repo, err := repoProviders.InitializeRepository(db)
	if err != nil {
		log.Fatal().Err(err).Msg("Error initializing repository")
	}

	customCtx := &config.CustomContext{
		Repository: repo,
	}

	engine := GetEngine(logger, customCtx)

	port := GetPort()

	log.Info().Msgf("Running server on port %s", port)

	if err = engine.Run(fmt.Sprintf(":%s", port)); err != nil {
		log.Fatal().Err(err).Msg("Unable to start server")
	}
}
