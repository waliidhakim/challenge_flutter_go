package services

import (
	"backend/initializers"
	"backend/models"
	"backend/utils"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GroupChatGet godoc
// @Summary Get group chats
// @Description Retrieves group chats associated with the authenticated user or all if admin
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} GroupChat "List of group chats"
// @Router /group-chat [get]
func GetGroupChats(context *gin.Context) []models.GroupChat {
	var groupChats []models.GroupChat
	userId, _ := context.Get("userId")

	fmt.Printf("--------------------Get chatgroups userID: %d---------------------------\n", userId)

	if utils.IsAdmin(context) {
		initializers.DB.Preload("Users.User").Find(&groupChats)
	} else {
		// Récupérer les groupes dont l'utilisateur est le propriétaire ou membre
		initializers.DB.Preload("Users.User").
			Joins("JOIN group_chat_users ON group_chat_users.group_chat_id = group_chats.id").
			Where("group_chat_users.user_id = ?", userId).
			Group("group_chats.id"). // Utiliser le groupement pour éviter les doublons
			Find(&groupChats)
	}

	return groupChats
}

func GetAllGroupChats(context *gin.Context) []models.GroupChat {
	var groupChats []models.GroupChat

	// Récupérer les utilisateurs avec pagination
	initializers.DB.Find(&groupChats)

	// Renvoyer les utilisateurs avec le statut HTTP 200
	context.JSON(http.StatusOK, groupChats)

	return groupChats
}
