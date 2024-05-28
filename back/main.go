package main

import (
	"backend/controllers"
	"backend/initializers"
	"backend/middlewares"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

func init() {
	initializers.InitLogger()
	initializers.LoadEnvVars()
	initializers.DbConnect()
}

func main() {

	// db.Create(&Test{Name: "Exemple", Value: "Valeur"})

	gin.SetMode(os.Getenv("GIN_MODE"))
	router := gin.Default()
	router.Use(cors.New(cors.Config{
		AllowOrigins:  []string{"*"},
		AllowMethods:  []string{"PUT", "PATCH, GET, DELETE", "POST"},
		AllowHeaders:  []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders: []string{"Content-Length"},
        AllowCredentials: true, //for cookies
		MaxAge:        12 * time.Hour,
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
	router.PATCH("/user/:id", controllers.UserUpdate)
	router.DELETE("/user/:id", middlewares.RequireAuth, controllers.UserDelete)
	router.POST("/user/login", controllers.UserLogin)

	err := router.Run()
	if err != nil {
		panic("Error starting server")
	}
}
