package main

import (
	"fmt"
	"os"
	"strconv"
)

type Settings struct {
	MqttConnectionString string
	ListenPort           int
}

func getSettings() (Settings, error) {
	mqttConnectionString := os.Getenv("MQTT_CONNECTION_STRING")
	if len(mqttConnectionString) == 0 {
		mqttConnectionString = "tcp://0.0.0.0:1883"
	}

	listenPortStr := os.Getenv("LISTEN_PORT")
	if listenPortStr == "" {
		listenPortStr = "9030"
	}
	listenPort, err := strconv.Atoi(listenPortStr)
	if err != nil {
		return Settings{}, fmt.Errorf("Could not parse listen port as an integer: %w", err)
	}

	settings := Settings{
		MqttConnectionString: mqttConnectionString,
		ListenPort:           listenPort,
	}

	return settings, nil
}
