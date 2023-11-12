
APP_NAME ?= rambler-frontend

all: install run

install:
	yarn install

run:
	yarn start

test:
	npx playwright test

to:
	npx playwright test --ui

clean:
	rm -rf node_modules
	docker rmi ${APP_NAME}

image:
	docker build . -t ${APP_NAME}

container: image
	docker run -p 3000:3000 --rm -it ${APP_NAME}
