package controllers

import (
	"backend/initializers"
	"backend/models"
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"net/http"
	"os"
	"time"
)

func UserGet(context *gin.Context) {
	var users []models.User
	initializers.DB.Find(&users)
	context.JSON(http.StatusOK, users)
}

func UserGetById(context *gin.Context) {
	id := context.Param("id")
	var user models.User
	initializers.DB.First(&user, id)
	context.JSON(http.StatusOK, user)
}

func UserPost(context *gin.Context) {
	var body struct {
		Firstname string
		Lastname  string
		Username  string
		Password  string
		Phone     string
	}

	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	user := models.User{
		Firstname: body.Firstname,
		Lastname:  body.Lastname,
		Username:  body.Username,
		Phone:     body.Phone,
		Password:  string(hashedPassword),
		AvatarUrl: "/default.png",
		Role:      "user",
	}
	result := initializers.DB.Create(&user)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			initializers.Logger.Infoln(result.Error)
			context.JSON(http.StatusBadRequest, gin.H{
				"error": "Phone should be unique",
			})
			return
		} else {
			initializers.Logger.Errorln(result.Error)
			context.Status(http.StatusInternalServerError)
			return
		}
	}
	context.JSON(http.StatusCreated, user)
}

func UserUpdate(context *gin.Context) {
	id := context.Param("id")
	var body struct {
		Firstname string
		Lastname  string
		Username  string
		Password  string
		Phone     string
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("UPDATE User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}
	var user models.User
	initializers.DB.First(&user, id)
	initializers.DB.Model(&user).Updates(models.User{
		Firstname: body.Firstname,
		Lastname:  body.Lastname,
		Username:  body.Username,
		Password:  body.Password,
		Phone:     body.Phone,
	})
	context.JSON(http.StatusOK, user)
}

func UserDelete(context *gin.Context) {
	id := context.Param("id")
	initializers.DB.Delete(&models.User{}, id)
	context.Status(http.StatusOK)
}

func UserLogin(context *gin.Context) {
	var body struct {
		Phone    string
		Password string
	}
	bindErr := context.Bind(&body)
	if bindErr != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}
	var user models.User
	initializers.DB.First(&user, "phone = ?", body.Phone)

	if user.ID == 0 {
		// Phone is unknown in that case but to avoid information disclosure we send a vague message
		context.JSON(http.StatusBadRequest, gin.H{
			"error": "Wrong phone or password",
		})
		return
	}

	bcryptErr := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
	if bcryptErr != nil {
		// User is found but password is wrong, to avoid information disclosure we send a vague message
		context.JSON(http.StatusBadRequest, gin.H{
			"error": "Wrong phone or password",
		})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,
		"exp": time.Now().Add(time.Hour * 6).Unix(),
	})

	tokenString, jwtErr := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if jwtErr != nil {
		initializers.Logger.Errorln("JWT Error when signing token", jwtErr)
		context.JSON(http.StatusInternalServerError, gin.H{
			"error": "Internal server error",
		})
		return
	}

	context.SetSameSite(http.SameSiteLaxMode)
	// @todo change "secure" to true when on production
	context.SetCookie("Authorization", tokenString, 3600*6, "", "", false, true)
	context.JSON(http.StatusOK, gin.H{})
}
