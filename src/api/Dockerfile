FROM golang:1.21 AS builder

WORKDIR /build

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install bc -y

COPY Makefile go.mod go.sum ./

RUN make install

COPY . ./

RUN make wire test

RUN go build -o ./main


FROM debian:stable

WORKDIR /backend

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install ca-certificates -y \
        && update-ca-certificates 2>/dev/null

COPY --from=builder /build/main ./main

COPY ./src/models/database/fixtures/ /build/src/models/database/fixtures/

EXPOSE 8000

ENTRYPOINT ["./main"]

