package main

import (
	"flag"
	log "github.com/Sirupsen/logrus"
	"github.com/wangr927/log-pilot/pilot"
	"io/ioutil"
	"os"
	"path/filepath"
)

func main() {
	template := flag.String("template", "", "Template filepath for filebeat.")
	base := flag.String("base", "", "Directory which mount host root.")
	flag.Parse()

	baseDir, err := filepath.Abs(*base)
	if err != nil {
		panic(err)
	}

	if baseDir == "/" {
		baseDir = ""
	}

	if *template == "" {
		panic("template file can not be empty")
	}

	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
	if os.Getenv("DEBUG") != "" {
		log.SetLevel(log.DebugLevel)
	}

	b, err := ioutil.ReadFile(*template)
	if err != nil {
		panic(err)
	}

	log.Fatal(pilot.Run(string(b), baseDir))
}
