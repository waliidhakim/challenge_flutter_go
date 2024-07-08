package main

import (
	"backend/controllers"
	"backend/initializers"
	"backend/middlewares"
	"backend/models"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"gorm.io/gorm"
)

var db *gorm.DB

type Message struct {
	Type        string `json:"type"`
	Username    string `json:"username"`
	Message     string `json:"message"`
	UserID      uint   `json:"user_id"`
	GroupChatID uint   `json:"group_chat_id"`
	SenderID    string `json:"sender_id"`
}

var clients = make(map[*websocket.Conn]bool)
var broadcast = make(chan Message)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func handleConnections(c *gin.Context) {
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

		// Handle typing and stop typing events
		if msg.Type == "typing" || msg.Type == "stop_typing" {
			broadcast <- msg
			continue
		}

		// Retrieve the username from the database
		var user models.User
		result := db.First(&user, msg.SenderID)
		if result.Error != nil {
			initializers.Logger.Errorf("Error retrieving user: %v", result.Error)
			continue
		}
		msg.Username = user.Username

		// Save the message to the database

		// Conversion de SenderID de string à uint64
		SenderIDAsUint64, err := strconv.ParseUint(msg.SenderID, 10, 64)
		if err != nil {
			fmt.Println("Erreur lors de la conversion de SenderID:", err)
			return
		}

		// Conversion de uint64 à uint
		SenderIDAsUint := uint(SenderIDAsUint64)

		groupChatMessage := models.GroupChatMessage{
			Message:     msg.Message,
			UserID:      SenderIDAsUint,
			GroupChatID: msg.GroupChatID,
		}
		result = db.Create(&groupChatMessage)
		if result.Error != nil {
			initializers.Logger.Errorf("Error saving message: %v", result.Error)
		} else {
			initializers.Logger.Infoln("Message saved to database")
		}

		// Add SenderID and type to the message
		//msg.SenderID = fmt.Sprintf("%d", msg.SenderID)
		msg.Type = "message"
		broadcast <- msg
	}
}

func handleMessages() {
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

func init() {
	initializers.InitLogger()
	initializers.LoadEnvVars()
	initializers.DbConnect()
	db = initializers.DB
}

func main() {
	gin.SetMode(os.Getenv("GIN_MODE"))
	router := gin.Default()
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"PUT", "PATCH, GET, DELETE", "POST"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true, // for cookies
		MaxAge:           12 * time.Hour,
	}))

	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	// USER Routes
	router.POST("/user", controllers.UserPost)
	router.GET("/user", controllers.UserGet)
	router.GET("/user/:id", controllers.UserGetById)
	router.PATCH("/user/:id", middlewares.RequireAuth, controllers.UserUpdate)
	router.DELETE("/user/:id", middlewares.RequireAuth, controllers.UserDelete)
	router.POST("/user/login", controllers.UserLogin)
	// test image upload
	router.POST("/user/with-image", controllers.UserPostWithImage)
	router.POST("/user/register", controllers.UserRegister)

	// GroupChat Routes
	router.GET("/group-chat", middlewares.RequireAuth, controllers.GroupChatGet)
	router.GET("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatGetById)
	router.POST("/group-chat", middlewares.RequireAuth, controllers.GroupChatPost)
	router.PATCH("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatUpdate)
	router.DELETE("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatDelete)
	router.GET("/group-chat/:id/messages", middlewares.RequireAuth, controllers.GroupChatGetMessages)

	router.GET("/unread-messages", middlewares.RequireAuth, controllers.GetUnreadMessages)

	// WebSocket route
	router.GET("/ws", func(c *gin.Context) {
		handleConnections(c)
	})

	go handleMessages()

	err := router.Run()
	if err != nil {
		initializers.Logger.Fatalf("Error starting server: %v", err)
	}
}
