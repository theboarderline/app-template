
APP_NAME ?= sample-api

EXECUTABLE_PATH ?= "bin/$(APP_NAME)"
COVERAGE_THRESHOLD ?= 70

all: clean wire build test image container

install:
	go mod download
	go get github.com/onsi/ginkgo/v2/ginkgo
	go get github.com/onsi/ginkgo/extensions/table
	go get github.com/onsi/gomega/...
	go install github.com/onsi/ginkgo/v2/ginkgo@latest
	go install github.com/wadey/gocovmerge@latest
	go install github.com/swaggo/swag/cmd/swag@latest
	go install github.com/google/wire/cmd/wire@latest

gen: swag wire

build:
	@echo "Building..."
	@go build -o $(EXECUTABLE_PATH)

run: build
	@echo "Running..."
	@./$(EXECUTABLE_PATH)

clean:
	@echo "Cleaning..."
	@rm -rf $(EXECUTABLE_PATH)

test:
	@echo "Testing..."
	@./bin/run_tests.sh $(COVERAGE_THRESHOLD)

swag:
	@echo "Generating swagger docs..."
	swag init

wire:
	@echo "Generating dependency graph..."
	wire ./...

image:
	@echo "Building image..."
	docker build . -t ${APP_NAME}

container:
	@echo "Running container..."
	docker run --rm -it -p 8000:8000 ${APP_NAME} -e "SECRET_KEY=fake-key"
