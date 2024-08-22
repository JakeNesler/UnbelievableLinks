package main

import (
	"html/template"
	"log"
	"unbelievablelinks/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.SetFuncMap(template.FuncMap{
		"inc": func(i int) int {
			return i + 1
		},
	})
	r.LoadHTMLGlob("templates/*.html")

	// Setup routes
	routes.SetupRoutes(r)

	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
