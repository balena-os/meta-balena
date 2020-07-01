package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	"github.com/alexgg/hostapp"
)

func main() {
	datarootPtr := flag.String("dataroot", "", "Docker root path e.g. /mnt/data/docker.")
	containerIDPtr := flag.String("container-id", "", "Container ID to mount filesystem from. The mount point is returned in stdout")
	flag.Parse()

	if *datarootPtr == "" {
		log.Printf("Data root path is required")
	}
	if *containerIDPtr == "" {
		log.Printf("Container ID is required")
	}

	rawGraphDriver, err := ioutil.ReadFile("/boot/storage-driver")
	if err != nil {
		log.Fatal("could not get storage driver:", err)
	}
	graphDriver := strings.TrimSpace(string(rawGraphDriver))
	log.Printf("Mounting %s with data root %s and storage driver %s", *containerIDPtr,*datarootPtr,graphDriver)
	newRootPath := hostapp.MountContainer(*datarootPtr, *containerIDPtr, graphDriver)
	fmt.Print(newRootPath)
}
