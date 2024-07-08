package controllers

import (
	"backend/initializers"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type UnreadMessagesResponse struct {
	GroupChatID uint `json:"group_chat_id"`
	Count       int  `json:"count"`
}

func GetUnreadMessages(c *gin.Context) {
	userID, exists := c.Get("userId")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
		return
	}

	// Initialize with an empty slice
	unreadMessages := []UnreadMessagesResponse{}

	result := initializers.DB.Table("group_chat_message_reads").
		Select("group_chat_id, COUNT(*) as count").
		Where("user_id = ? AND read_at IS NULL", userID).
		Group("group_chat_id").
		Scan(&unreadMessages)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch unread messages"})
		return
	}

	// Log for debugging
	fmt.Printf("Fetched unread messages: %+v\n", unreadMessages)
	initializers.Logger.Debugf("Fetched unread messages: %+v\n", unreadMessages)

	c.JSON(http.StatusOK, unreadMessages)
}
