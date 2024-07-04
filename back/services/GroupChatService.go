package services

import (
	"backend/initializers"
	"backend/models"
)

func GetGroupChats() []models.GroupChat {
	var groupChats []models.GroupChat
	initializers.DB.Find(&groupChats)

	return groupChats
}
