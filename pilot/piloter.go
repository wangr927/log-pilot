package pilot

import (
	"strings"
)

// Global variables for piloter
const (
	ENV_PILOT_TYPE = "PILOT_TYPE"
	PILOT_FILEBEAT = "filebeat"
)

// Piloter interface for piloter
type Piloter interface {
	Name() string
	Start() error
	Reload() error
	Stop() error
	GetBaseConf() string
	GetConfHome() string
	GetConfPath(container string) string
	OnDestroyEvent(container string) error
}

// CustomConfig custom config
func CustomConfig(name string, customConfigs map[string]string, logConfig *LogConfig) {
	fields := make(map[string]string)
	configs := make(map[string]string)
	for k, v := range customConfigs {
		if strings.HasPrefix(k, name) {
			key := strings.TrimPrefix(k, name+".")
			if strings.HasPrefix(key, "fields") {
				key2 := strings.TrimPrefix(key, "fields.")
				fields[key2] = v
			} else {
				configs[key] = v
			}
		}
	}
	logConfig.CustomFields = fields
	logConfig.CustomConfigs = configs
}
