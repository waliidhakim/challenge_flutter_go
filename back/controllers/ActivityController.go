package controllers

import (
	"backend/initializers"
	"backend/models"
	"github.com/gin-gonic/gin"
	"net/http"
	"time"
)

func ActivityParticipationGet(context *gin.Context) {
	var activityParticipation []models.GroupChatActivityParticipation
	initializers.DB.Find(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetByGroupChatID(context *gin.Context) {
	groupChatID := context.Param("group_chat_id")
	var activityParticipation []models.GroupChatActivityParticipation
	initializers.DB.Where("group_chat_id = ?", groupChatID).Find(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetByUserID(context *gin.Context) {
	userID := context.Param("user_id")
	var activityParticipation []models.GroupChatActivityParticipation
	initializers.DB.Where("user_id = ?", userID).Find(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationPost(context *gin.Context) {
	var body struct {
		GroupChatId       int
		ParticipationDate string
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST ActivityParticipation : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	userId, userErr := context.Get("userId")
	if userErr != true {
		initializers.Logger.Errorln("POST ActivityParticipation : Error getting user id from context")
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	parsedTime, errDate := time.Parse(time.RFC3339, body.ParticipationDate)
	if errDate != nil {
		initializers.Logger.Errorln("POST ActivityParticipation : Error parsing date")
		initializers.Logger.Errorln(errDate)
		context.Status(http.StatusInternalServerError)
		return
	}
	activityParticipation := models.GroupChatActivityParticipation{
		UserID:            userId.(uint),
		GroupChatID:       body.GroupChatId,
		ParticipationDate: parsedTime,
	}
	initializers.DB.Create(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationDelete(context *gin.Context) {
	id := context.Param("id")
	var activityParticipation models.GroupChatActivityParticipation
	initializers.DB.First(&activityParticipation, id)
	initializers.DB.Delete(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationPatch(context *gin.Context) {
	id := context.Param("id")
	var activityParticipation models.GroupChatActivityParticipation
	initializers.DB.First(&activityParticipation, id)

	var body struct {
		GroupChatID       int
		ParticipationDate time.Time
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("PATCH ActivityParticipation : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	activityParticipation.GroupChatID = body.GroupChatID
	activityParticipation.ParticipationDate = body.ParticipationDate
	initializers.DB.Save(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetById(context *gin.Context) {
	id := context.Param("id")
	var activityParticipation models.GroupChatActivityParticipation
	initializers.DB.First(&activityParticipation, id)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetByGroupChatIDAndUserID(context *gin.Context) {
	groupChatID := context.Param("group_chat_id")
	userID := context.Param("user_id")
	var activityParticipation []models.GroupChatActivityParticipation
	initializers.DB.Where("group_chat_id = ? AND user_id = ?", groupChatID, userID).Find(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetByGroupChatIDAndIsToday(context *gin.Context) {
	groupChatID := context.Param("group_chat_id")
	var activityParticipation []models.GroupChatActivityParticipation
	today := time.Now().Format("2006-01-02")
	initializers.DB.Where("group_chat_id = ? AND DATE(participation_date) = ?", groupChatID, today).Find(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}

func ActivityParticipationGetByGroupChatIDAndUserIDAndIsToday(context *gin.Context) {
	groupChatID := context.Param("group_chat_id")
	userID := context.MustGet("userId")
	today := time.Now().Format("2006-01-02")
	var activityParticipation models.GroupChatActivityParticipation
	initializers.DB.Where("group_chat_id = ? AND user_id = ? AND DATE(participation_date) = ?", groupChatID, userID, today).First(&activityParticipation)
	context.JSON(http.StatusOK, activityParticipation)
}
