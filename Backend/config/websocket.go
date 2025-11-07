package config

import (
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)


var (
	Broadcast = make(chan []byte)
	Clients   = make(map[*websocket.Conn]bool)
	ClientsMutex = sync.Mutex{}
	Upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
    	WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
)