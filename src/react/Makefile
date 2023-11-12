
APP_NAME ?= sample-frontend

all: install test run

reset: clean install

install:
	yarn install

test:
	npx playwright test

build-dev:
	yarn build

run:
	yarn start

to:
	npx playwright test --ui

clean:
	rm -rf node_modules yarn.lock
	docker rmi ${APP_NAME} || true

image:
	docker build . -t ${APP_NAME}

container: image
	docker run -p 3000:3000 --rm -it ${APP_NAME}
