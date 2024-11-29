package main

import (
	"log"
	"os"
	"os/signal"

	"github.com/gorilla/websocket"
)

func main() {
	// Connect to the WebSocket server
	url := "ws://localhost:8080/ws"
	conn, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		log.Fatal("Dial error:", err)
	}
	defer conn.Close()

	// Signal handling for graceful shutdown
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	done := make(chan struct{})

	// Start a goroutine to read messages from the server
	go func() {
		defer close(done)
		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				log.Println("Read error:", err)
				return
			}
			log.Printf("Received: %s\n", message)
		}
	}()

	// Send a test message to the server
	err = conn.WriteMessage(websocket.TextMessage, []byte("Hello, Server!"))
	if err != nil {
		log.Println("Write error:", err)
		return
	}

	// Wait for an interrupt signal to close gracefully
	select {
	case <-done:
	case <-interrupt:
		log.Println("Interrupt received, closing connection...")
		conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
	}
}
