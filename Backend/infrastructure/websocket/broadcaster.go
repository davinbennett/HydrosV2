package websocket

import (
	"log"
	"main/config"

	"github.com/gorilla/websocket"
)

func StartBroadcaster() {
	for msg := range config.Broadcast {
		config.ClientsMutex.Lock()
		for conn := range config.Clients {
			if err := conn.WriteMessage(websocket.TextMessage, msg); err != nil {
				log.Printf("WebSocket send error: %v", err)
				conn.Close()
				delete(config.Clients, conn)
			}
		}
		config.ClientsMutex.Unlock()
	}
}

