package websocket

import (
	"log"
	"main/config"
)

func StartBroadcaster() {
	for {
		msg := <-config.Broadcast

		for conn := range config.Clients {
			err := conn.WriteMessage(1, msg)
			if err != nil {
				log.Printf("WebSocket send error: %v", err)
				conn.Close()
				delete(config.Clients, conn)
			}
		}
	}
}
