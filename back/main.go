package main

import (
	"backend/controllers"
	"backend/initializers"
	"backend/middlewares"
	"backend/models"
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

	// Assurez-vous que le modèle Notification est migré
	db.AutoMigrate(&models.Notification{})
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

	// Notification Routes
	router.GET("/notifications/:id", middlewares.RequireAuth, controllers.GetNotificationById)
	router.GET("/notifications/", middlewares.RequireAuth, controllers.GetNotifications)
	router.POST("/notifications", middlewares.RequireAuth, controllers.CreateNotification)

	// GroupChatActivity Routes
	router.GET("/group-chat-activity", middlewares.RequireAuth, controllers.ActivityParticipationGet)
	router.GET("/group-chat-activity/:id", middlewares.RequireAuth, controllers.ActivityParticipationGetById)
	router.GET("/group-chat-activity/group-chat/:group_chat_id", middlewares.RequireAuth, controllers.ActivityParticipationGetByGroupChatID)
	router.GET("/group-chat-activity/user/:user_id", middlewares.RequireAuth, controllers.ActivityParticipationGetByUserID)
	router.POST("/group-chat-activity", middlewares.RequireAuth, controllers.ActivityParticipationPost)
	router.PATCH("/group-chat-activity/:id", middlewares.RequireAuth, controllers.ActivityParticipationPatch)
	router.DELETE("/group-chat-activity/:id", middlewares.RequireAuth, controllers.ActivityParticipationDelete)
	router.GET("/group-chat-activity/group-chat/:group_chat_id/today-participation", middlewares.RequireAuth, controllers.ActivityParticipationGetByGroupChatIDAndIsToday)
	router.GET("/group-chat-activity/user/:user_id/group-chat/:group_chat_id", middlewares.RequireAuth, controllers.ActivityParticipationGetByGroupChatIDAndUserID)
	router.GET("/group-chat-activity/group-chat/:group_chat_id/my-today-participation", middlewares.RequireAuth, controllers.ActivityParticipationGetByGroupChatIDAndUserIDAndIsToday)

	// GroupChatActivityLocation Routes
	router.GET("/group-chat-activity-location", middlewares.RequireAuth, controllers.ActivityLocationGet)
	router.GET("/group-chat-activity-location/group-chat/:group_chat_id", middlewares.RequireAuth, controllers.ActivityLocationGetByGroupChatID)
	router.POST("/group-chat-activity-location", middlewares.RequireAuth, controllers.ActivityLocationCreate)
	router.DELETE("/group-chat-activity-location/:id", middlewares.RequireAuth, controllers.ActivityLocationDelete)

	// GroupChatActivityLocationVote Routes
	router.GET("/group-chat-activity-location-vote", middlewares.RequireAuth, controllers.ActivityLocationVoteGet)
	router.GET("/group-chat-activity-location-vote/group-chat/:group_chat_id/today", middlewares.RequireAuth, controllers.ActivityLocationVoteGetByGroupIdToday)
	router.GET("/group-chat-activity-location-vote/location/:location_id/today", middlewares.RequireAuth, controllers.ActivityLocationVoteGetByLocationIdToday)
	router.POST("/group-chat-activity-location-vote", middlewares.RequireAuth, controllers.ActivityLocationVoteCreate)
	router.DELETE("/group-chat-activity-location-vote/user-location/:location_id/today", middlewares.RequireAuth, controllers.ActivityLocationVoteDeleteByUserAndLocationIdToday)
	router.DELETE("/group-chat-activity-location-vote/user-location/group/:group_id/today", middlewares.RequireAuth, controllers.ActivityLocationVoteDeleteByGroupAndUser)
	router.DELETE("/group-chat-activity-location-vote/:id", middlewares.RequireAuth, controllers.ActivityLocationVoteDelete)
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
