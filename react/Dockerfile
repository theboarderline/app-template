# Use yarn image to compile React app
FROM gcr.io/cloud-builders/yarn as build
WORKDIR /react
COPY . .

RUN yarn global add sass
RUN yarn install
RUN yarn build


# Use custom nginx image with built-in configs to serve compiled React app
FROM gcr.io/walker-cpl/nginx-react:0.0.2

COPY --from=build /react/build/ /var/www/html/



