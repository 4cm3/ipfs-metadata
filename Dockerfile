FROM golang:1.23-alpine AS build

WORKDIR /app

COPY go.mod ./
COPY *.go ./

RUN go mod tidy
RUN go build -o /ipfs_fetcher

## Using a smaller image to run our application
FROM alpine:3.21
WORKDIR /

RUN addgroup -S app && adduser -S app -G app
USER app

COPY data/ipfs_cids.csv /data/ipfs_cids.csv
COPY .env.empty /.env
COPY --from=build /ipfs_fetcher /ipfs_fetcher
EXPOSE 8080

ENTRYPOINT ["/ipfs_fetcher"]