package middlewares

import (
	"backend/initializers"
	"backend/models"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"net/http"
	"os"
	"time"
)

func RequireAuth(context *gin.Context) {
	tokenString, cookieErr := context.Cookie("Authorization")
	if cookieErr != nil {
		context.AbortWithStatus(http.StatusUnauthorized)
		return
	}

	token, jwtErr := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("JWT_SECRET")), nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Checking for the token expiration time
		if float64(time.Now().Unix()) > claims["exp"].(float64) {
			context.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		// Checking for the user attached to that token
		var user models.User
		initializers.DB.First(&user, claims["sub"])
		if user.ID == 0 {
			context.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		context.Set("userRole", user.Role)
		context.Set("userId", user.ID)
	} else {
		initializers.Logger.Errorln(jwtErr)
		context.AbortWithStatus(http.StatusUnauthorized)
	}

	context.Next()
}
