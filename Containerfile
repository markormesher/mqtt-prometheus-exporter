FROM docker.io/golang:1.25.2@sha256:1c91b4f4391774a73d6489576878ad3ff3161ebc8c78466ec26e83474855bfcf as builder
WORKDIR /app

ARG CGO_ENABLED=0

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM ghcr.io/markormesher/scratch:v0.4.2@sha256:d6e4bea349b975ed5f3a124fc63c8dae0a67507d081bed206de9e50b6bcbe87f
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/mqtt-prometheus-exporter

COPY --from=builder /app/build/main /usr/local/bin/mqtt-prometheus-exporter

CMD ["/usr/local/bin/mqtt-prometheus-exporter"]
