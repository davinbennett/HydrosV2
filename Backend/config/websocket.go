package config

import (
	"github.com/gorilla/websocket"
	"net/http"
)

var Clients = make(map[*websocket.Conn]bool)
var Broadcast = make(chan []byte)

var Upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true 
	},
}