package services

import (
	"backend/initializers"
	"backend/models"
	"backend/utils"
	"fmt"

	"github.com/gin-gonic/gin"
)

func GetGroupChats(context *gin.Context) []models.GroupChat {
	var groupChats []models.GroupChat
	// userID := context.MustGet("userId").(uint)
	userId, _ := context.Get("userId")

	fmt.Printf("--------------------Get chatgroups userID: %d---------------------------\n", userId)

	if utils.IsAdmin(context) {
		initializers.DB.Preload("Users").Find(&groupChats)
	} else {
		// Récupérer les groupes dont l'utilisateur est le propriétaire ou membre
		initializers.DB.Preload("Users").
			Joins("JOIN group_chat_users ON group_chat_users.group_chat_id = group_chats.id").
			Where("group_chat_users.user_id = ?", userId).
			Group("group_chats.id"). // Utiliser le groupement pour éviter les doublons
			Find(&groupChats)
	}

	return groupChats
}
