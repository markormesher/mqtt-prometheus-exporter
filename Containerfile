FROM docker.io/golang:1.27.4@sha256:5e8afd493a7124a8586e134d9b532731161d4b9becf9dee5a5956b107426f93d as builder
WORKDIR /app

ARG CGO_ENABLED=0

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM ghcr.io/markormesher/scratch:v0.4.32@sha256:71f46deac9e113a52927d263f2bc05a05bde9cb92d2a2ebf6136c0430c5e4c91
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
