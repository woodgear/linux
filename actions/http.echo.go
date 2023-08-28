package main

import (
	"log"
	"net/http"
	"os"
	"fmt"
)
// CGO_ENABLED=0 go build -a -installsuffix cgo -o http-echo ./actions/http.echo.go
func echoHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("src %s \n", r.RemoteAddr)
	_, err := w.Write([]byte("hello"))
	if err != nil {
		http.Error(w, "Failed to echo request body", http.StatusInternalServerError)
		return
	}
}

func main() {
	if len(os.Args) < 2 {
		log.Fatalf("Usage: %s <port>", os.Args[0])
	}

	port := os.Args[1]
	http.HandleFunc("/", echoHandler)

	log.Printf("Starting server on http://localhost:%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
