package urls

import (
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func AddRoutes(engine *gin.Engine) {

	basePath := "/api"

	// Public
	public := engine.Group(basePath)

	public.GET("/")
	public.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

}
