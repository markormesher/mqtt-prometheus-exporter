FROM docker.io/golang:1.24.1@sha256:52ff1b35ff8de185bf9fd26c70077190cd0bed1e9f16a2d498ce907e5c421268 as builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM gcr.io/distroless/base-debian12@sha256:27769871031f67460f1545a52dfacead6d18a9f197db77110cfc649ca2a91f44
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/mqtt-prometheus-exporter

COPY --from=builder /app/build/main /usr/local/bin/mqtt-prometheus-exporter

CMD ["/usr/local/bin/mqtt-prometheus-exporter"]
