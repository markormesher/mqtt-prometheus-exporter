package main

import (
	"fmt"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var topicPatterns = []regexp.Regexp{
	*regexp.MustCompile(`^\$SYS/broker/uptime$`),
	*regexp.MustCompile(`^\$SYS/broker/clients/(connected|expired|disconnected|maximum|total)$`),
	*regexp.MustCompile(`^\$SYS/broker/store/messages/(count|bytes)$`),
	*regexp.MustCompile(`^\$SYS/broker/(bytes|messages)/(sent|received|stored)$`),
}

func main() {
	settings, err := getSettings()
	if err != nil {
		l.Error("failed to load settings", "err", err)
		os.Exit(1)
	}

	metrics := newMetrics()

	mqttOpts := mqtt.NewClientOptions()
	mqttOpts.AddBroker(settings.MqttConnectionString)
	mqttOpts.AutoReconnect = true
	mqttOpts.OnConnect = func(_ mqtt.Client) {
		l.Info("connecting to MQTT server...")
	}
	mqttOpts.OnReconnecting = func(_ mqtt.Client, _ *mqtt.ClientOptions) {
		l.Info("re-connecting to MQTT server...")
	}

	mqttClient := mqtt.NewClient(mqttOpts)
	if token := mqttClient.Connect(); token.Wait() && token.Error() != nil {
		l.Error("failed to connect to mqtt server", "err", err)
		os.Exit(1)
	}

	mqttClient.Subscribe("$SYS/#", 0, func(c mqtt.Client, m mqtt.Message) {
		topic := m.Topic()
		keepTopic := false
		for _, pattern := range topicPatterns {
			if pattern.MatchString(topic) {
				keepTopic = true
				break
			}
		}

		if !keepTopic {
			return
		}

		metricName := strings.ReplaceAll(topic, "$SYS", "mqtt")
		metricName = strings.ReplaceAll(metricName, "/", "_")

		valueStr := string(m.Payload())
		valueStr = strings.TrimSuffix(valueStr, " seconds")
		value, err := strconv.ParseFloat(valueStr, 32)
		if err != nil {
			l.Warn("invalid value received", "err", err)
			return
		}

		metrics.Add(metricName, float32(value))
	})

	http.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("content-type", "text/plain")
		w.Write([]byte(metrics.Flush()))
	})
	err = http.ListenAndServe(fmt.Sprintf(":%d", settings.ListenPort), nil)
	if err != nil {
		l.Error("http server failed", "err", err)
		os.Exit(1)
	}
}
