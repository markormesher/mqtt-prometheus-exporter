package main

import (
	"fmt"
	"sync"
)

type Metrics struct {
	metrics map[string]float32
	lock    *sync.Mutex
}

func newMetrics() Metrics {
	return Metrics{
		metrics: map[string]float32{},
		lock:    &sync.Mutex{},
	}
}

func (m *Metrics) Add(name string, value float32) {
	m.lock.Lock()
	defer m.lock.Unlock()

	m.metrics[name] = value
}

func (m *Metrics) Flush() string {
	m.lock.Lock()
	defer m.lock.Unlock()

	out := ""

	for key, value := range m.metrics {
		out += fmt.Sprintf("%s %.2f\n", key, value)
	}

	return out
}
