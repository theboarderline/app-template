package main

import (
	"fmt"
	"github.com/spf13/viper"
	"net/url"
	"os"
	"strings"
)

func getUserEmail(role string) string {
	key := fmt.Sprintf("%s_EMAIL", strings.ToUpper(role))
	return os.Getenv(key)
}

func getUserPassword(role string) string {
	key := fmt.Sprintf("%s_PASSWORD", strings.ToUpper(role))
	return os.Getenv(key)
}

func getUrl(method string, serviceName string, path string) (serviceUrl string) {

	apiURL, ok := os.LookupEnv("API_URL")
	if ok {
		return fmt.Sprintf("%s/%s%s", apiURL, serviceName, path)
	} else {

		domain := viper.GetString("domain")

		var scheme string
		var serviceDomain string

		lifecycle := viper.GetString("lifecycle")

		if lifecycle == "local" {

			if method == "WS" {
				scheme = "ws"
			} else {
				scheme = "http"
			}
			serviceDomain = "localhost:8000"

		} else {
			if method == "WS" {
				scheme = viper.GetString("ws_scheme")
			} else {
				scheme = viper.GetString("http_scheme")
			}

			if lifecycle != "prod" {
				serviceDomain = fmt.Sprintf("%s.%s", lifecycle, domain)
			} else {
				serviceDomain = domain
			}
		}

		path = fmt.Sprintf("%s%s", serviceName, path)

		u := url.URL{Scheme: scheme, Host: serviceDomain, Path: path}

		return u.String()
	}
}

func GetTestFilePath(filename string) string {
	return fmt.Sprintf("./sample-files/%s", filename)
}
