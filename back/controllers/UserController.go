package controllers

import (
	"backend/initializers"
	"backend/models"
	"github.com/gin-gonic/gin"
	"net/http"
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

	user := models.User{
		Firstname: body.Firstname,
		Lastname:  body.Lastname,
		Username:  body.Username,
		Phone:     body.Phone,
		Password:  body.Password,
		AvatarUrl: "/default.png",
		Role:      "user",
	}
	result := initializers.DB.Create(&user)
	if result.Error != nil {
		context.Status(http.StatusInternalServerError)
		return
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
