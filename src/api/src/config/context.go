package config

import (
	"context"
	"github.com/gin-gonic/gin"
	groupme "github.com/theboarderline/groupme-utilities/client"
	"github.com/theboarderline/sample/api/src/models"
	"github.com/theboarderline/sample/api/src/repository"
)

type CustomContext struct {
	Repository    *repository.Repository
	GroupmeClient groupme.Client
}

var CustomContextKey = "CUSTOM_CONTEXT"
var GinContextKey = "GIN_CONTEXT"
var UserKey = "USER"

func GetGinContext(ctx context.Context) *gin.Context {
	ginContext, ok := ctx.Value(GinContextKey).(*gin.Context)
	if !ok {
		return nil
	}

	return ginContext
}

func GetContext(ctx context.Context) *CustomContext {
	customContext, ok := ctx.Value(CustomContextKey).(*CustomContext)
	if !ok {
		return nil
	}

	return customContext
}

func GetUser(ctx context.Context) *models.User {
	user, ok := ctx.Value(UserKey).(*models.User)
	if !ok {
		return nil
	}

	return user
}

func CustomContextMiddleware(customCtx *CustomContext) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := context.WithValue(c.Request.Context(), CustomContextKey, customCtx)
		c.Request = c.Request.WithContext(ctx)
		c.Next()
	}
}
