package routes

import (
	"encoding/csv"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

type Website struct {
	Category    string
	Name        string
	Link        string
	Description string
}

// Load websites from CSV file
func loadWebsites(filePath string) ([]Website, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	var websites []Website
	for i, record := range records[1:] {
		if len(record) != 4 {
			log.Printf("Skipping malformed record at line %d: %v", i+2, record)
			continue
		}
		websites = append(websites, Website{
			Category:    record[0],
			Name:        record[1],
			Link:        record[2],
			Description: record[3],
		})
	}
	return websites, nil
}

// Extract unique categories
func extractCategories(websites []Website) []string {
	categorySet := make(map[string]struct{})
	for _, website := range websites {
		categorySet[website.Category] = struct{}{}
	}
	var categories []string
	for category := range categorySet {
		categories = append(categories, category)
	}
	return categories
}

// SetupRoutes initializes the routes for the application
func SetupRoutes(r *gin.Engine) {
	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	// Load websites from CSV
	websites, err := loadWebsites("data/websites.csv")
	if err != nil {
		log.Fatalf("Failed to load websites: %v", err)
	}

	categories := extractCategories(websites)

	// Display all links by default
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{
			"Title":      "UnbelievableLinks",
			"Links":      websites,
			"Categories": categories,
		})
	})

	// Handle search queries
	r.GET("/search", func(c *gin.Context) {
		query := c.Query("q")
		var results []Website
		for _, site := range websites {
			if strings.Contains(strings.ToLower(site.Name), strings.ToLower(query)) ||
				strings.Contains(strings.ToLower(site.Description), strings.ToLower(query)) ||
				strings.Contains(strings.ToLower(site.Category), strings.ToLower(query)) {
				results = append(results, site)
			}
		}

		// If no search query is provided, show all links
		if query == "" {
			results = websites
		}

		c.HTML(http.StatusOK, "index.html", gin.H{
			"Title":      "Search Results",
			"Links":      results,
			"Categories": categories,
		})
	})
}
