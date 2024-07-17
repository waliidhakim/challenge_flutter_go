package controllers

import (
	"backend/initializers"
	"backend/models"
	"github.com/gin-gonic/gin"
	"net/http"
)

func ActivityLocationGet(context *gin.Context) {
	var activityLocations []models.GroupChatActivityLocation
	initializers.DB.Find(&activityLocations)
	context.JSON(http.StatusOK, activityLocations)
}

func ActivityLocationGetByGroupChatID(context *gin.Context) {
	groupChatID := context.Param("group_chat_id")
	var activityLocations []models.GroupChatActivityLocation
	initializers.DB.Where("group_chat_id = ?", groupChatID).Find(&activityLocations)
	context.JSON(http.StatusOK, activityLocations)
}

func ActivityLocationCreate(context *gin.Context) {
	var body struct {
		Name        string
		Address     string
		GroupChatId int
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln(err)
		context.JSON(http.StatusBadRequest, gin.H{"error": "Error while binding request"})
	}
	location := &models.GroupChatActivityLocation{
		GroupChatID: body.GroupChatId,
		Name:        body.Name,
		Address:     body.Address,
	}
	initializers.DB.Create(&location)
	context.JSON(http.StatusCreated, location)
}

func ActivityLocationDelete(context *gin.Context) {
	locationID := context.Param("id")
	var location models.GroupChatActivityLocation
	initializers.DB.Where("id = ?", locationID).First(&location)
	if location.ID == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "Location not found"})
		return
	}
	initializers.DB.Delete(&location)
	context.JSON(http.StatusOK, gin.H{"message": "Location deleted"})
}
