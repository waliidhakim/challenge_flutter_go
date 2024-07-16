package main

import (
	"backend/controllers"
	"backend/initializers"
	"backend/middlewares"
	"backend/services"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

var db *gorm.DB

func init() {
	initializers.InitLogger()
	initializers.LoadEnvVars()
	initializers.DbConnect()
	db = initializers.DB
	controllers.InitFirebase()
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
	router.GET("/user", middlewares.RequireAuth, controllers.UserGet)
	router.GET("/user/:id", controllers.UserGetById)
	router.PATCH("/user/:id", middlewares.RequireAuth, controllers.UserUpdate)
	router.DELETE("/user/:id", middlewares.RequireAuth, controllers.UserDelete)
	router.POST("/user/login", controllers.UserLogin)
	router.POST("/user/admin/login", controllers.AdminLogin)
	router.GET("/users/:id/group_chat_activity_participations", middlewares.RequireAuth, controllers.UserGetGroupChatActivityParticipations)
	// User settings
	router.GET("/settings", middlewares.RequireAuth, controllers.SettingGet)
	router.GET("/settings/user/:id", middlewares.RequireAuth, controllers.SettingGetByUserId)
	router.GET("/settings/user", middlewares.RequireAuth, controllers.SettingGetUser)
	router.PATCH("/settings/user", middlewares.RequireAuth, controllers.SettingUserUpdate)
	router.POST("/settings", middlewares.RequireAuth, controllers.SettingPost)
	router.PATCH("/settings/:id", middlewares.RequireAuth, controllers.SettingUpdate)
	router.DELETE("/settings/:id", middlewares.RequireAuth, controllers.SettingDelete)
	// Test image upload
	router.POST("/user/with-image", controllers.UserPostWithImage)
	router.POST("/user/register", controllers.UserRegister)

	// GroupChat Routes
	router.GET("/group-chat", middlewares.RequireAuth, controllers.GroupChatGet)
	router.GET("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatGetById)
	router.POST("/group-chat", middlewares.RequireAuth, controllers.GroupChatPost)
	router.PATCH("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatUpdate)
	router.DELETE("/group-chat/:id", middlewares.RequireAuth, controllers.GroupChatDelete)
	router.GET("/group-chat/:id/messages", middlewares.RequireAuth, controllers.GroupChatGetMessages)
	router.PATCH("/group-chat/infos/:id", middlewares.RequireAuth, controllers.GroupChatUpdateInfos)
	router.GET("/unread-messages", middlewares.RequireAuth, controllers.GetUnreadMessages)

    router.POST("/send-notification", controllers.SendNotification)
    
	// WebSocket route
	router.GET("/ws", func(c *gin.Context) {
		services.HandleConnections(c)
	})

	services.InitWebSocket(db)

	err := router.Run()
	if err != nil {
		initializers.Logger.Fatalf("Error starting server: %v", err)
	}
}
