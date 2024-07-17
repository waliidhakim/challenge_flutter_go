package main

import (
	"backend/controllers"
	"backend/initializers"
	"backend/middlewares"
	"backend/services"
	"backend/utils"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	httpSwagger "github.com/swaggo/http-swagger"
	"gorm.io/gorm"
)

var db *gorm.DB

func init() {
	initializers.InitLogger()
	initializers.InitDailyLogger()
	initializers.LoadEnvVars()
	initializers.DbConnect()
	db = initializers.DB
	//controllers.InitFirebase()
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

	// @Summary Ping example
	// @Schemes
	// @Description Do ping
	// @Tags Example
	// @Accept json
	// @Produce json
	// @Success 200 {object} map[string]interface{}
	// @Router / [get]
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

	// Feature Flipping fonctionnalité
	// Feature Management Routes
	router.GET("/features", middlewares.RequireAuth, controllers.FeaturesList)
	router.POST("/features", middlewares.RequireAuth, controllers.FeatureCreate)
	router.GET("/features/:id", middlewares.RequireAuth, controllers.FeatureGet)
	router.PATCH("/features/:id", middlewares.RequireAuth, controllers.FeatureUpdate)
	router.DELETE("/features/:id", middlewares.RequireAuth, controllers.FeatureDelete)

	// WebSocket route
	router.GET("/ws", func(c *gin.Context) {
		services.HandleConnections(c)
	})

	router.GET("/swagger/*any", gin.WrapH(httpSwagger.Handler(
		httpSwagger.URL("/docs/swagger.json"), // URL vers le fichier swagger.json
	)))

	router.Static("/docs", "./docs")

	services.InitWebSocket(db)

	go utils.UploadLogsEveryTenSeconds()

	err := router.Run()
	if err != nil {
		initializers.Logger.Fatalf("Error starting server: %v", err)
	}
}
