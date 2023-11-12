package repository_test

import (
	"github.com/go-faker/faker/v4"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/theboarderline/sample/api/src/models"
	"github.com/theboarderline/sample/api/src/testutils"
)

var _ = Describe("Users", func() {
	var (
		testUser      *models.User
		testUserInput models.User
	)

	BeforeEach(func() {
		testUserInput = models.User{
			FirstName: faker.FirstName(),
			LastName:  faker.LastName(),
			Phone:     faker.Phonenumber(),
			Email:     faker.Email(),
			Password:  faker.Password(),
		}
		var err error
		testUser, err = repo.UserRepository.Create(testUserInput)
		Expect(err).NotTo(HaveOccurred())
		Expect(testUser).NotTo(BeNil())
		Expect(testUser.ID).NotTo(BeZero())
		Expect(testUser.FirstName).To(Equal(testUserInput.FirstName))
		Expect(testUser.LastName).To(Equal(testUserInput.LastName))
		Expect(testUser.Phone).To(Equal(testUserInput.Phone))
		Expect(testUser.Password).NotTo(BeNil())
		Expect(testUser.Email).NotTo(BeNil())
		Expect(testUser.Email).To(Equal(testUserInput.Email))
	})

	AfterEach(func() {
		err := repo.UserRepository.Delete(testUser.ID)
		Expect(err).NotTo(HaveOccurred())

		user, err := repo.UserRepository.GetByID(testUser.ID)
		Expect(err).To(HaveOccurred())
		Expect(user).To(BeNil())
	})

	It("can fail if a user with an existing email is created", func() {
		_, err := repo.UserRepository.Create(testUserInput)
		Expect(err).To(HaveOccurred())
		Expect(err.Error()).To(Equal("email already exists"))
	})

	It("can get a user by id", func() {
		user, err := repo.UserRepository.GetByID(testUser.ID)
		Expect(err).NotTo(HaveOccurred())
		testutils.AssertUserEquals(user, testUser)
	})

	It("can get a user by email and password", func() {
		user, err := repo.UserRepository.GetByEmailPassword(testUserInput.Email, testUserInput.Password)
		Expect(err).NotTo(HaveOccurred())
		testutils.AssertUserEquals(user, testUser)
	})

	It("can get a user by phone number", func() {
		user, err := repo.UserRepository.GetByPhone(testUser.Phone)
		Expect(err).NotTo(HaveOccurred())
		testutils.AssertUserEquals(user, testUser)

	})

	It("can error if email is not provided", func() {
		user, err := repo.UserRepository.GetByEmail("")
		Expect(err).To(HaveOccurred())
		Expect(user).To(BeNil())
	})

	It("can get a user by email", func() {
		user, err := repo.UserRepository.GetByEmail(testUser.Email)
		Expect(err).NotTo(HaveOccurred())
		testutils.AssertUserEquals(user, testUser)
	})

	It("can throw an error if a user is not found", func() {
		user, err := repo.UserRepository.ResetPassword(testUser.ID + 1)
		Expect(err).To(HaveOccurred())
		Expect(user).To(BeNil())
	})

	It("can reset a user's password", func() {
		user, err := repo.UserRepository.ResetPassword(testUser.ID)
		Expect(err).NotTo(HaveOccurred())
		Expect(user.PlainTextPassword).NotTo(Equal(testUserInput.Password))
	})

	It("can get all users", func() {
		users, err := repo.UserRepository.GetAll()
		Expect(err).NotTo(HaveOccurred())
		Expect(users).NotTo(BeNil())
		Expect(len(users)).NotTo(BeZero())
	})

	It("can update a user", func() {
		userInput := models.User{
			ID:        testUser.ID,
			FirstName: faker.FirstName(),
			LastName:  faker.LastName(),
			Phone:     faker.Phonenumber(),
			Email:     faker.Email(),
			Role:      "admin",
		}

		user, err := repo.UserRepository.Update(userInput)
		Expect(err).NotTo(HaveOccurred())
		Expect(user).NotTo(BeNil())
		Expect(user.ID).To(BeEquivalentTo(userInput.ID))
		Expect(user.FirstName).To(Equal(userInput.FirstName))
		Expect(user.LastName).To(Equal(userInput.LastName))
		Expect(user.Phone).To(Equal(userInput.Phone))
		Expect(user.Email).To(Equal(userInput.Email))
	})

})
