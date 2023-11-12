package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/cucumber/godog"
	"github.com/cucumber/godog/colors"
	"github.com/go-faker/faker/v4"
	"github.com/go-resty/resty/v2"
	"github.com/hasura/go-graphql-client"
	"github.com/joho/godotenv"
	. "github.com/onsi/gomega"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"
)

type apiFeature struct {
	client           *resty.Client
	gqlClient        *graphql.Client
	res              interface{}
	response         Response
	statusCode       int
	authToken        string
	err              error
	user             User
	marina           interface{}
	id               int
	lastMutationName string
}

func (a *apiFeature) resetResponse(interface{}) {
	a.client = resty.New()
	a.gqlClient = graphql.NewClient(fmt.Sprintf("%s://%s/api/graphql", viper.GetString("http_scheme"), viper.GetString("domain")), a.client.GetClient())
	a.response = Response{}
	a.res = ""
	a.statusCode = 0
	a.authToken = ""
	a.user = User{}
	a.marina = nil
	a.id = 0
	a.lastMutationName = ""
	a.err = nil
}

func (a *apiFeature) signedIn(service, role, endpoint string) {

	loginInput := LoginRequest{
		Email:    getUserEmail(role),
		Password: getUserPassword(role),
	}

	req := a.client.R().
		SetHeader("Content-Type", "application/json").
		SetBody(loginInput)

	a.makeRequest(req, "POST", service, endpoint, nil, "")

	a.response = Response{}
	err := json.Unmarshal([]byte(fmt.Sprint(a.res)), &a.response)
	Expect(err).NotTo(HaveOccurred())

	Expect(a.response.Message).To(ContainSubstring("Successfully logged in"))

	a.authToken = a.response.Token
	Expect(a.authToken).NotTo(BeEmpty())

	a.user.Email = getUserEmail(role)
}

func (a *apiFeature) sendSignupRequest(service string, endpoint string) {

	password := faker.Password()

	signupInput := SignupRequest{
		FirstName:       faker.FirstName(),
		LastName:        faker.LastName(),
		Email:           faker.Email(),
		Password:        password,
		ConfirmPassword: password,
		Phone:           faker.Phonenumber(),
	}

	req := a.client.R().
		SetHeader("Content-Type", "application/json").
		SetBody(signupInput)

	a.makeRequest(req, "POST", service, endpoint, nil, "")

	a.response = Response{}
	err := json.Unmarshal([]byte(fmt.Sprint(a.res)), &a.response)
	Expect(err).To(BeNil())
	Expect(a.statusCode).To(Equal(http.StatusCreated))

	a.user.Phone = signupInput.Phone
	a.user.Email = signupInput.Email
	a.user.Password = password

	a.authToken = a.response.Token

	Expect(a.authToken).To(Not(BeEmpty()))
	a.client.SetAuthToken(a.authToken)
}

func (a *apiFeature) sendLoginRequestWithCurrentUser(service string, endpoint string) {

	loginInput := LoginRequest{
		Email:    a.user.Email,
		Password: a.user.Password,
	}

	req := a.client.R().
		SetHeader("Content-Type", "application/json").
		SetBody(loginInput)

	a.makeRequest(req, "POST", service, endpoint, nil, "")

	a.response = Response{}
	err := json.Unmarshal([]byte(fmt.Sprint(a.res)), &a.response)
	Expect(err).To(BeNil())
}

func (a *apiFeature) sendLoginRequest(service string, endpoint string) {

	loginInput := LoginRequest{
		Phone: a.user.Phone,
	}

	req := a.client.R().
		SetHeader("Content-Type", "application/json").
		SetBody(loginInput)

	a.makeRequest(req, "POST", service, endpoint, nil, "")
}

func (a *apiFeature) sendRequestWithData(method string, service string, endpoint string, body *godog.DocString) {
	req := a.client.R().
		SetHeader("Content-Type", "application/json").
		SetBody(a.replaceValues(body.Content))

	if a.authToken != "" {
		req.SetAuthToken(a.authToken)
	}

	a.makeRequest(req, method, service, endpoint, nil, "")

}

func (a *apiFeature) sendRequest(method string, service string, endpoint string) {
	req := a.client.R()

	a.makeRequest(req, method, service, endpoint, nil, "")
}

func (a *apiFeature) sendRequestWithToken(method string, service string, endpoint string) {
	secretKey := os.Getenv("SECRET_KEY")
	req := a.client.R().
		SetAuthToken(secretKey)

	a.makeRequest(req, method, service, endpoint, nil, "")
}

func (a *apiFeature) sendRequestWithFileAndData(filename string, serviceName string, endpoint string, body *godog.DocString) {
	a.makeRequest(nil, "POST", serviceName, endpoint, body, filename)
}

func (a *apiFeature) saveToken() {
	a.authToken = a.response.Token

	Expect(a.authToken).To(Not(BeEmpty()))
	a.client.SetAuthToken(a.authToken)
}

func (a *apiFeature) theResponseCodeShouldBe(statusCode int) {
	actual := a.statusCode
	expected := statusCode
	Expect(actual).To(Equal(expected))
}

func (a *apiFeature) theResponseResultsShouldNotBeEmpty() {
	Expect(a.response.Results).To(Not(BeEmpty()))
}

func (a *apiFeature) theResponseShouldContain(body *godog.DocString) {
	actual := trimString(fmt.Sprint(a.res))
	expected := trimString(body.Content)
	Expect(actual).To(ContainSubstring(expected))
}

func (a *apiFeature) theResponseShouldContainA(key string) {
	res, err := json.Marshal(a.res)
	Expect(err).To(BeNil())

	actual := trimString(string(res))
	Expect(actual).To(ContainSubstring(key))
}

func (a *apiFeature) theResponseShouldNotContainA(key string) {
	res, err := json.Marshal(a.res)
	Expect(err).To(BeNil())

	actual := trimString(string(res))
	Expect(actual).NotTo(ContainSubstring(key))
}

func (a *apiFeature) theResponseShouldMatchJSON(body *godog.DocString) {
	actual := a.res
	expected := body.Content
	Expect(actual).To(MatchJSON(expected))
}

func (a *apiFeature) makeRequest(req *resty.Request, method string, serviceName string, endpoint string, body *godog.DocString, filename string) {
	if req == nil {
		req = a.client.R()
	}

	if body != nil {
		req.SetHeader("Content-Type", "application/json").
			SetBody(a.replaceValues(body.Content))

		log.Info().Msgf("SETTING BODY: %s", body.Content)
	}

	if filename != "" {
		req.SetFile("file", GetTestFilePath(filename))

		log.Info().Msgf("SETTING FILE: %s", filename)
	}

	if a.authToken != "" {
		req.SetHeader("Authorization", fmt.Sprintf("Bearer %s", a.authToken))

		log.Info().Msgf("SETTING AUTH TOKEN HEADERS")
	}

	var response *resty.Response
	var err error

	url := getUrl(method, serviceName, endpoint)

	switch method {

	case "GET":
		log.Info().Msgf("GET: %s", url)
		response, err = req.Get(url)

	case "POST":
		log.Info().Msgf("POST: %s", url)
		response, err = req.Post(url)

	case "PUT":
		log.Info().Msgf("PUT: %s", url)
		response, err = req.Put(url)

	case "PATCH":
		log.Info().Msgf("PATCH: %s", url)
		response, err = req.Patch(url)

	case "DELETE":
		log.Info().Msgf("DELETE: %s", url)
		response, err = req.Delete(url)
	}

	log.Info().Msgf("RESPONSE: %v", response)

	a.res = response.String()
	a.statusCode = response.StatusCode()
	a.err = err

	Expect(a.err).To(BeNil())
}

func (a *apiFeature) saveObjectID(mutation string) {
	var dataMap map[string]interface{}
	json.Unmarshal([]byte(fmt.Sprint(a.res)), &dataMap)

	data := dataMap["data"]
	response, ok := data.(map[string]interface{})
	Expect(ok).To(BeTrue())

	res, ok := response[mutation].(map[string]interface{})
	Expect(ok).To(BeTrue())

	id, ok := res["id"]
	Expect(ok).To(BeTrue())

	a.id = int(id.(float64))
	Expect(a.id).NotTo(BeZero())

	a.lastMutationName = mutation
}

func (a *apiFeature) replaceValues(input string) string {
	return strings.Replace(input, "${id}", fmt.Sprint(a.id), -1)
}
func replaceLifecycle(data []byte) []byte {
	formattedString := strings.Replace(string(data), "$LIFECYCLE", fmt.Sprint(viper.Get("lifecycle")), -1)
	return []byte(formattedString)
}

func InitializeScenario(ctx *godog.ScenarioContext) {
	api := &apiFeature{}

	ctx.Before(func(ctx context.Context, sc *godog.Scenario) (context.Context, error) {
		api.resetResponse(sc)
		return ctx, nil
	})

	ctx.Step(`^I am logged in to the "([^"]*)" service as a "([^"]*)" using "([^"]*)"$`, api.signedIn)
	ctx.Step(`^I send "(GET|POST|DELETE)" request to the "([^"]*)" service at "([^"]*)"$`, api.sendRequest)
	ctx.Step(`^I send "([^"]*)" request to the "([^"]*)" service at "([^"]*)" with the secret key$`, api.sendRequestWithToken)
	ctx.Step(`^I send the file named "([^"]*)" to the "([^"]*)" service at "([^"]*)" with data$`, api.sendRequestWithFileAndData)

	ctx.Step(`^I send "(WSS|PATCH|POST|PUT)" request to the "([^"]*)" service at "([^"]*)" with data$`, api.sendRequestWithData)
	ctx.Step(`^I send a signup request to the "([^"]*)" service at "([^"]*)" with random data$`, api.sendSignupRequest)
	ctx.Step(`^I send a login request to the "([^"]*)" service at "([^"]*)" with the current user$`, api.sendLoginRequestWithCurrentUser)
	ctx.Step(`^I send a login request to the "([^"]*)" service at "([^"]*)" for the current user$`, api.sendLoginRequest)
	ctx.Step(`^the token should be saved for future requests$`, api.saveToken)
	ctx.Step(`^the response code should be "([^"]*)"$`, api.theResponseCodeShouldBe)
	ctx.Step(`^the response code should be (\d+)$`, api.theResponseCodeShouldBe)
	ctx.Step(`^the response results should not be empty$`, api.theResponseResultsShouldNotBeEmpty)
	ctx.Step(`^the response should match json$`, api.theResponseShouldMatchJSON)
	ctx.Step(`^the response should contain a$`, api.theResponseShouldContainA)
	ctx.Step(`^the response should contain$`, api.theResponseShouldContain)
	ctx.Step(`^the response should contain a "([^"]*)"$`, api.theResponseShouldContainA)
	ctx.Step(`^the response should not contain a "([^"]*)"$`, api.theResponseShouldNotContainA)

	ctx.Step(`^the id from the "([^"]*)" request should be saved$`, api.saveObjectID)
}

var opts = godog.Options{
	Paths:     []string{"features"},
	Output:    colors.Colored(os.Stdout),
	Randomize: time.Now().UTC().UnixNano(),
	Format:    "pretty",
}

func init() {
	godog.BindCommandLineFlags("godog.", &opts)

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

	_ = godotenv.Load(".env")

	viper.SetConfigName("config")
	viper.AddConfigPath(".")

	viper.SetDefault("lifecycle", "dev")
	viper.SetDefault("region", "na")
	viper.SetDefault("http_scheme", "https")
	viper.SetDefault("ws_scheme", "wss")

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			log.Warn().Msg("Config file not found; ignore error if desired")
		} else {
			log.Warn().Err(err).Msg("Config file was found but another error was produced")
		}
	}

	pflag.StringP("lifecycle", "l", viper.GetString("lifecycle"), "lifecycle to run tests against")
	pflag.Parse()
	viper.BindPFlags(pflag.CommandLine)
}

func TestMain(m *testing.M) {
	RegisterFailHandler(func(message string, _ ...int) {
		panic(message)
	})

	status := godog.TestSuite{
		ScenarioInitializer: InitializeScenario,
		Options:             &opts,
	}.Run()

	os.Exit(status)
}
