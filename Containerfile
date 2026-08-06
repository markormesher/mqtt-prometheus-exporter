FROM docker.io/golang:1.26.5@sha256:2005724102f45917a63e9d092fc0e4ea56ea575048ce147caad5f5f61502c365 as builder
WORKDIR /app

ARG CGO_ENABLED=0

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM ghcr.io/markormesher/scratch:v0.4.24@sha256:82cfb48166d3129439d10e8f10b79063209ae16cd54de131b6c87173f8eea758
WORKDIR /app

COPY --from=builder /app/build/main /usr/local/bin/mqtt-prometheus-exporter

CMD ["/usr/local/bin/mqtt-prometheus-exporter"]

LABEL image.name=markormesher/mqtt-prometheus-exporter
LABEL image.registry=ghcr.io
LABEL org.opencontainers.image.description=""
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.title="mqtt-prometheus-exporter"
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.version=""
