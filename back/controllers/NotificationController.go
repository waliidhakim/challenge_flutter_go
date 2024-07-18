package controllers

import (
	"backend/initializers"
	"backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// CreateNotification handles creating a new notification
func CreateNotification(c *gin.Context) {
	var input models.Notification
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	notification := models.Notification{
		Title:         input.Title,
		Description:   input.Description,
		Timestamp:     input.Timestamp,
		GroupName:     input.GroupName,
		SenderName:    input.SenderName,
		GroupImageUrl: input.GroupImageUrl,
		UserID:        input.UserID,
		GroupChatID:   input.GroupChatID,
		MessageID:     input.MessageID,
	}

	result := initializers.DB.Create(&notification)
	if result.Error != nil {
		initializers.Logger.Debugf("Notification creations erroor %v", result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create notification"})
		return
	}

	c.JSON(http.StatusOK, notification)
}

// GetNotifications handles retrieving notifications for a user
func GetNotifications(c *gin.Context) {
	userID, exists := c.Get("userId")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
		return
	}

	var notifications []models.Notification
	result := initializers.DB.Where("user_id = ?", userID).Find(&notifications)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
		return
	}

	c.JSON(http.StatusOK, notifications)
}

func GetNotificationById(c *gin.Context) {
	// userID, exists := c.Get("userId")
	// if !exists {
	// 	c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
	// 	return
	// }

	var notifications []models.Notification
	// result := initializers.DB.Where("user_id = ?", userID).Find(&notifications)
	// if result.Error != nil {
	// 	c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
	// 	return
	// }

	c.JSON(http.StatusOK, notifications)
}
