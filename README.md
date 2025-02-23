![CircleCI](https://img.shields.io/circleci/build/github/markormesher/mqtt-prometheus-exporter)

# MQTT Prometheus Exporter

A simple Prometheus exporter to expose the value of some `$SYS` topics from an MQTT broker.

Note that whilst there is _some_ standardisation between brokers for `$SYS` topics, this project is developed against the popular [Mosquitto](https://mosquitto.org) broker. PRs to support other brokers are welcome.

:rocket: Jump to [quick-start example](#quick-start-docker-compose-example).

:whale: See releases on [ghcr.io](https://ghcr.io/markormesher/mqtt-prometheus-exporter).

## Measurements

- `mqtt_broker_bytes_sent/received`
- `mqtt_broker_clients_connected/disconnected/expired/maximum/total`
- `mqtt_broker_messages_sent/received/stored`
- `mqtt_broker_store_messages_bytes/count`
- `mqtt_broker_uptime`

See [`cmd/main.go`](./cmd/main.go) for the full list.

## Configuration

Configuration is via the following environment variables:

- `MQTT_CONNECTION_STRING` - MQTT connection string, including protocol, host and port (default: `mqtt://0.0.0.0:1883`).
- `LISTEN_PORT` - Port for the HTTP server (optional, default: `9030`).

## Quick-Start Docker-Compose Example

```yaml
version: "3.8"

services:
  mqtt-prometheus-exporter:
    image: ghcr.io/markormesher/mqtt-prometheus-exporter:VERSION
    restart: unless-stopped
    environment:
      - MQTT_CONNECTION_STRING=mqtt://mqtt.example.com:1883
    ports:
      - 9030:9030
```
