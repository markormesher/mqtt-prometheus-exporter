FROM docker.io/golang:1.24.3@sha256:81bf5927dc91aefb42e2bc3a5abdbe9bb3bae8ba8b107e2a4cf43ce3402534c6 as builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM gcr.io/distroless/base-debian12@sha256:cef75d12148305c54ef5769e6511a5ac3c820f39bf5c8a4fbfd5b76b4b8da843
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/mqtt-prometheus-exporter

COPY --from=builder /app/build/main /usr/local/bin/mqtt-prometheus-exporter

CMD ["/usr/local/bin/mqtt-prometheus-exporter"]
