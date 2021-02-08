package main

import "os"

func Getenv(name, def string) string {
	if value := os.Getenv(name); value == "" {
		return def
	} else {
		return value
	}
}
