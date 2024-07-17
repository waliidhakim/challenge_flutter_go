// websocket_service.go
package services

import (
	"backend/initializers"
	"backend/models"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"gorm.io/gorm"
)

type Message struct {
	Type         string                                 `json:"type"`
	Username     string                                 `json:"username"`
	Message      string                                 `json:"message"`
	UserID       uint                                   `json:"user_id"`
	GroupChatID  uint                                   `json:"group_chat_id"`
	SenderID     string                                 `json:"sender_id"`
	CreatedAt    time.Time                              `json:"created_at"` // Ajout de created_at
	Participants int                                    `json:"nb_participants"`
	Votes        []models.GroupChatActivityLocationVote `json:"votes"`
}

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan Message)
var db *gorm.DB

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func InitWebSocket(database *gorm.DB) {
	db = database
	go HandleMessages()
}

func HandleConnections(c *gin.Context) {
	initializers.Logger.Infoln("New WebSocket connection established")
	ws, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		initializers.Logger.Fatalf("Failed to upgrade to WebSocket: %v", err)
	}
	defer func() {
		initializers.Logger.Infoln("WebSocket connection closed")
		ws.Close()
	}()

	clients[ws] = true
	clientID := ws.RemoteAddr().String()
	initializers.Logger.Infof("Client connected: %v", clientID)

	for {
		var msg Message
		err := ws.ReadJSON(&msg)
		if err != nil {
			initializers.Logger.Infof("Error reading JSON: %v", err)
			delete(clients, ws)
			break
		}

		initializers.Logger.Debugf("Received message: %v from user: %v in group: %v", msg.Message, msg.SenderID, msg.GroupChatID)

		if msg.Type == "group_participants" {
			broadcast <- msg
			msg.Participants = 0
			continue
		}

		if msg.Type == "group_votes" {
			// List of votes with location_id, user_id and count
			fmt.Println("GROUP VOTES WS")
			var activityLocationsVote []models.GroupChatActivityLocationVote
			initializers.DB.Where("group_id = ?", msg.GroupChatID).Find(&activityLocationsVote)
			msg.Votes = activityLocationsVote
			fmt.Println("Votes:", activityLocationsVote)
			broadcast <- msg
			continue
		}

		if msg.Type == "typing" || msg.Type == "stop_typing" {
			broadcast <- msg
			continue
		}

		if msg.Type == "message" {
			var user models.User
			result := db.First(&user, msg.SenderID)
			if result.Error != nil {
				initializers.Logger.Errorf("Error retrieving user: %v", result.Error)
				continue
			}
			msg.Username = user.Username

			SenderIDAsUint64, err := strconv.ParseUint(msg.SenderID, 10, 64)
			if err != nil {
				fmt.Println("Erreur lors de la conversion de SenderID:", err)
				return
			}
			SenderIDAsUint := uint(SenderIDAsUint64)

			groupChatMessage := models.GroupChatMessage{
				Message:     msg.Message,
				UserID:      SenderIDAsUint,
				GroupChatID: msg.GroupChatID,
				CreatedAt:   msg.CreatedAt,
			}
			result = db.Create(&groupChatMessage)
			if result.Error != nil {
				initializers.Logger.Errorf("Error saving message: %v", result.Error)
			} else {
				initializers.Logger.Infoln("Message saved to database")
			}

			msg.Type = "message"
			broadcast <- msg
		}
	}
}

func HandleMessages() {
	for {
		msg := <-broadcast
		initializers.Logger.Infof("Broadcasting message: %v", msg.Message)
		for client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				initializers.Logger.Errorf("Error writing JSON to client: %v", err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
