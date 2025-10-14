package config

import (
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var (
	Upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}

	Clients      = make(map[*websocket.Conn]bool)
	ClientsMutex sync.Mutex

	Broadcast = make(chan []byte)
)
