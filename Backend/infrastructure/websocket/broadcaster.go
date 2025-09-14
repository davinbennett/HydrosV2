package websocket

import (
	"log"
	"main/config"

	"github.com/gorilla/websocket"
)

func StartBroadcaster() string{
	for msg := range config.Broadcast {

		for conn := range config.Clients {
			if err := conn.WriteMessage(websocket.TextMessage, msg); err != nil {
				log.Printf("WebSocket send error: %v", err)
				conn.Close()
				delete(config.Clients, conn)
			}
		}
	}

	return ""
}
