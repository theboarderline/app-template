FROM node:18-bullseye-slim as build

WORKDIR /react

COPY package.json yarn.lock ./

RUN yarn install

COPY . .

RUN yarn build


# Build custom nginx image with to serve compiled React app
FROM gcr.io/walker-cpl/nginx-react:0.1.3

COPY --from=build /react/build/ /var/www/html/


