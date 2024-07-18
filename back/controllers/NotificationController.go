package controllers

import (
	"backend/initializers"
	"backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func NotificationGet(context *gin.Context) {
	var notifications []models.Notification
	initializers.DB.Find(&notifications)
	context.JSON(http.StatusOK, notifications)
}

func NotificationGetByUserId(context *gin.Context) {
	UserID, err := context.Get("userId")
	if err != true {
		initializers.Logger.Errorln("POST ActivityParticipation : Error getting user id from context")
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var notifications []models.Notification
	initializers.DB.Where("user_id = ?", UserID).Find(&notifications)
	context.JSON(http.StatusOK, notifications)
}

func NotificationPost(context *gin.Context) {
	var body struct {
		Title   string
		Content string
		UserID  uint
		GroupId int
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln(err)
		context.JSON(http.StatusBadRequest, gin.H{"error": "Error while binding request"})
	}
	var group models.GroupChat
	initializers.DB.First(&group, body.GroupId)
	notification := &models.Notification{
		Title:            body.Title,
		NotificationIcon: group.ImageUrl,
		DateTime:         time.Now(),
		GroupName:        group.Name,
		Content:          body.Content,
		UserID:           body.UserID,
		GroupId:          body.GroupId,
	}
	initializers.DB.Create(&notification)
	context.JSON(http.StatusCreated, notification)
}
