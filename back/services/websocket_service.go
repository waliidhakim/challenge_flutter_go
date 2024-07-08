package services

// import (
// 	"backend/initializers"
// 	"backend/models"
// 	"fmt"
// 	"net/http"

// 	"github.com/gorilla/websocket"
// 	"gorm.io/gorm"
// )

// type Message struct {
// 	Type        string `json:"type"`
// 	Username    string `json:"username"`
// 	Message     string `json:"message"`
// 	UserID      uint   `json:"user_id"`
// 	GroupChatID uint   `json:"group_chat_id"`
// 	SenderID    string `json:"sender_id"`
// }

// var clients = make(map[*websocket.Conn]bool)
// var broadcast = make(chan Message)
// var db *gorm.DB

// var upgrader = websocket.Upgrader{
// 	ReadBufferSize:  1024,
// 	WriteBufferSize: 1024,
// 	CheckOrigin: func(r *http.Request) bool {
// 		return true
// 	},
// }

// func InitWebSocket(database *gorm.DB) {
// 	db = database
// 	go handleMessages()
// }

// func HandleConnections(w http.ResponseWriter, r *http.Request) {
// 	initializers.Logger.Infoln("New WebSocket connection established")
// 	ws, err := upgrader.Upgrade(w, r, nil)
// 	if err != nil {
// 		initializers.Logger.Fatalf("Failed to upgrade to WebSocket: %v", err)
// 	}
// 	defer func() {
// 		initializers.Logger.Infoln("WebSocket connection closed")
// 		ws.Close()
// 	}()

// 	clients[ws] = true
// 	clientID := ws.RemoteAddr().String()
// 	initializers.Logger.Infof("Client connected: %v", clientID)

// 	for {
// 		var msg Message
// 		err := ws.ReadJSON(&msg)
// 		if err != nil {
// 			initializers.Logger.Infof("Error reading JSON: %v", err)
// 			delete(clients, ws)
// 			break
// 		}

// 		initializers.Logger.Infof("Received message: %v from user: %v in group: %v", msg.Message, msg.UserID, msg.GroupChatID)

// 		if msg.Type == "typing" || msg.Type == "stop_typing" {
// 			broadcast <- msg
// 			continue
// 		}

// 		var user models.User
// 		result := db.First(&user, msg.UserID)
// 		if result.Error != nil {
// 			initializers.Logger.Errorf("Error retrieving user: %v", result.Error)
// 			continue
// 		}
// 		msg.Username = user.Username

// 		groupChatMessage := models.GroupChatMessage{
// 			Message:     msg.Message,
// 			UserID:      msg.UserID,
// 			GroupChatID: msg.GroupChatID,
// 		}
// 		result = db.Create(&groupChatMessage)
// 		if result.Error != nil {
// 			initializers.Logger.Errorf("Error saving message: %v", result.Error)
// 		} else {
// 			initializers.Logger.Infoln("Message saved to database")
// 		}

// 		msg.SenderID = fmt.Sprintf("%d", msg.UserID)
// 		msg.Type = "message"
// 		broadcast <- msg
// 	}
// }

// func handleMessages() {
// 	for {
// 		msg := <-broadcast
// 		initializers.Logger.Infof("Broadcasting message: %v", msg.Message)
// 		for client := range clients {
// 			err := client.WriteJSON(msg)
// 			if err != nil {
// 				initializers.Logger.Errorf("Error writing JSON to client: %v", err)
// 				client.Close()
// 				delete(clients, client)
// 			}
// 		}
// 	}
// }
