FROM golang:1.13.5-alpine

RUN apk add --no-cache git ca-certificates

ENV GO111MODULE=on

WORKDIR /hydra

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go mod verify
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o hydra

FROM scratch

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=0 /hydra/hydra /usr/bin/hydra

ENTRYPOINT ["hydra"]

CMD ["serve", "all"]