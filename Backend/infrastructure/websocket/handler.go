package websocket

import (
	"log"
	"main/config"
	"net/http"

)

func HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := config.Upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}

	config.ClientsMutex.Lock()
	config.Clients[conn] = true
	log.Println("✅ New WebSocket client connected")
	config.ClientsMutex.Unlock()

	go func() {
		defer func() {
			conn.Close()
			config.ClientsMutex.Lock()
			delete(config.Clients, conn)
			config.ClientsMutex.Unlock()
			log.Println("WebSocket client disconnected")
		}()

		for {
			if _, _, err := conn.ReadMessage(); err != nil {
				break
			}
		}
	}()
}
