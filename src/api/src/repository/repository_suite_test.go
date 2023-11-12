package repository_test

import (
	"github.com/theboarderline/sample/api/src/repository"
	"github.com/theboarderline/sample/api/src/testutils"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var (
	repo *repository.Repository
)

func TestRepository(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Repository Suite")
}

var _ = BeforeSuite(func() {
	repo = testutils.GetTestRepository()
	Expect(repo).NotTo(BeNil())
})
