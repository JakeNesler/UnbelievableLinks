#!/bin/bash

# Set the project name
PROJECT_NAME="unbelievablelinks"

# Create the directory structure
mkdir -p $PROJECT_NAME/templates
mkdir -p $PROJECT_NAME/data

# Create the main.go file
cat <<EOL > $PROJECT_NAME/main.go
package main

import (
    "encoding/csv"
    "html/template"
    "log"
    "net/http"
    "os"
    "github.com/gin-gonic/gin"
)

type Website struct {
    Category    string
    Rank        string
    Name        string
    Link        string
    Description string
}

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
    for _, record := range records[1:] { // Skip header
        websites = append(websites, Website{
            Category:    record[0],
            Rank:        record[1],
            Name:        record[2],
            Link:        record[3],
            Description: record[4],
        })
    }
    return websites, nil
}

func main() {
    r := gin.Default()

    r.SetFuncMap(template.FuncMap{
        "inc": func(i int) int {
            return i + 1
        },
    })
    r.LoadHTMLGlob("templates/*.html")

    // Load websites from CSV
    websites, err := loadWebsites("data/websites.csv")
    if err != nil {
        log.Fatalf("Failed to load websites: %v", err)
    }

    r.GET("/", func(c *gin.Context) {
        c.HTML(http.StatusOK, "index.html", gin.H{
            "Title": "UnbelievableLinks",
            "Links": websites[:5], // Display first 5 as interactive
            "List":  websites,      // Display the entire list on the right
        })
    })

    r.Run(":8080")
}
EOL

# Create the layout.html file
cat <<EOL > $PROJECT_NAME/templates/layout.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ .Title }}</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-900 text-white">
    <header class="bg-blue-800 py-6">
        <div class="container mx-auto text-center">
            <h1 class="text-4xl font-bold">UnbelievableLinks</h1>
            <p class="text-lg mt-2">Curated by Unbelievable Site Web Consultants</p>
        </div>
    </header>
    <main class="container mx-auto my-10">
        {{ block "content" . }}{{ end }}
    </main>
    <footer class="bg-blue-800 py-4">
        <div class="container mx-auto text-center">
            <p>&copy; 2024 Unbelievable Site Web Consultants. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
EOL

# Create the index.html file
cat <<EOL > $PROJECT_NAME/templates/index.html
{{ define "content" }}
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Interactive Links -->
    <div class="space-y-4">
        {{ range .Links }}
        <a href="{{ .Link }}" class="block bg-gray-800 p-6 rounded-lg shadow-lg hover:bg-gray-700 transition duration-300">
            <h2 class="text-2xl font-semibold mb-2">{{ .Name }}</h2>
            <p class="text-gray-400">{{ .Description }}</p>
        </a>
        {{ end }}
    </div>
    <!-- List of Top Websites -->
    <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
        <h2 class="text-2xl font-semibold mb-4">Top 100 Websites</h2>
        <ul class="space-y-2">
            {{ range .List }}
            <li class="text-lg"><span class="font-bold">{{ .Rank }}.</span> <a href="{{ .Link }}" class="text-blue-400 hover:underline">{{ .Name }}</a> - {{ .Description }}</li>
            {{ end }}
        </ul>
    </div>
</div>
{{ end }}
EOL

# Create the websites.csv file
cat <<EOL > $PROJECT_NAME/data/websites.csv
category,rank,name,link,description
AI,1,ChatGPT,https://chat.openai.com,The best AI assistant on the web.
Design,2,Canva,https://www.canva.com,Create beautiful designs effortlessly.
Security,3,Have I Been Pwned,https://haveibeenpwned.com,Check if your email or phone number has been compromised.
EOL

# Print completion message
echo "Project structure for '$PROJECT_NAME' has been created."
