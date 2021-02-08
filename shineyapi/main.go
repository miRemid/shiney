package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func route() *gin.Engine {
	router := gin.New()
	router.Use(gin.Logger())
	router.Use(gin.Recovery())

	router.GET("/getImages", GetImageURLS)

	return router
}

func main() {
	log.SetFlags(log.Llongfile)
	server := http.Server{
		Handler: route(),
		Addr:    Getenv("ADDRESS", ":5000"),
	}

	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
