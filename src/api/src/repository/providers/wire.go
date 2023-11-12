//go:build wireinject
// +build wireinject

package repo_providers

import (
	"github.com/google/wire"
	"github.com/theboarderline/sample/api/src/repository"
	"gorm.io/gorm"
)

func InitializeRepository(db *gorm.DB) (*repository.Repository, error) {
	wire.Build(
		repository.NewUserRepository,
		wire.Struct(new(repository.Repository), "*"),
	)
	return &repository.Repository{}, nil
}
