package controllers

import (
	"backend/initializers"
	"backend/models"
	"backend/services"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GroupChatGet(context *gin.Context) {
	var groupChats = services.GetGroupChats()
	context.JSON(http.StatusOK, groupChats)

}

func GroupChatGetById(context *gin.Context) {
	grouChatId := context.Param("id")
	userId, exists := context.Get("userId")
	if !exists {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
		return
	}

	userID, ok := userId.(uint)
	if !ok {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "User ID is not of type uint"})
		return
	}

	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ?", grouChatId, userID).First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusForbidden, gin.H{"error": "Access to the specified group chat is forbidden or group chat does not exist"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Si trouvé, récupérer le GroupChat
	var groupChat models.GroupChat
	result = initializers.DB.First(&groupChat, grouChatId)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusNotFound, gin.H{"error": "Group chat not found"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error when retrieving group chat"})
		return
	}

	// Renvoyer le GroupChat
	context.JSON(http.StatusOK, groupChat)
}

func GroupChatPost(context *gin.Context) {
	var body struct {
		Name        string
		Activity    string
		CatchPhrase string
	}

	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST GroupChat : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	userId, exists := context.Get("userId")
	if !exists {
		initializers.Logger.Errorln("User ID not found in the context")
		context.Status(http.StatusUnauthorized)
		return
	}

	// userId est du bon type
	userID, ok := userId.(uint)
	if !ok {
		initializers.Logger.Errorln("User ID is not of type uint")
		context.Status(http.StatusInternalServerError)
		return
	}

	groupChat := models.GroupChat{
		Name:        body.Name,
		Activity:    body.Activity,
		CatchPhrase: body.CatchPhrase,
	}
	result := initializers.DB.Create(&groupChat)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			initializers.Logger.Infoln(result.Error)
			context.JSON(http.StatusBadRequest, gin.H{
				"error": "Group chat name should be unique",
			})
			return
		} else {
			initializers.Logger.Errorln(result.Error)
			context.Status(http.StatusInternalServerError)
			return
		}
	}

	// Création de l'association dans GroupChatUser
	groupChatUser := models.GroupChatUser{
		GroupChatID: groupChat.ID,
		UserID:      userID,
		Role:        "owner",
	}
	result = initializers.DB.Create(&groupChatUser)
	if result.Error != nil {
		initializers.Logger.Errorln("Error linking user to group chat:", result.Error)
		context.Status(http.StatusInternalServerError)
		return
	}

	// Réponse avec le group chat créé
	context.JSON(http.StatusCreated, gin.H{
		"groupChatID": groupChat.ID,
		"userID":      userID,
		"role":        groupChatUser.Role,
	})
}

func GroupChatUpdate(context *gin.Context) {
	id := context.Param("id")

	userId, exists := context.Get("userId")
	if !exists {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
		return
	}

	// Assurez-vous que userId est du bon type, ici on suppose que c'est un uint
	userID, ok := userId.(uint)
	if !ok {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "User ID is not of type uint"})
		return
	}

	// Structure pour les données entrantes
	var updateData struct {
		Name        string `json:"name"`
		Activity    string `json:"activity"`
		CatchPhrase string `json:"catchPhrase"`
	}
	if err := context.BindJSON(&updateData); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data"})
		return
	}

	// Vérifier si l'utilisateur est le propriétaire du GroupChat
	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ? AND role = ?", id, userID, "owner").First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this group chat"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Mise à jour du GroupChat
	update := initializers.DB.Model(&models.GroupChat{}).Where("id = ?", id).Updates(models.GroupChat{
		Name:        updateData.Name,
		Activity:    updateData.Activity,
		CatchPhrase: updateData.CatchPhrase,
	})
	if update.Error != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update group chat"})
		return
	}

	// Renvoyer la réponse
	if update.RowsAffected == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "No group chat found with the given ID"})
		return
	}
	context.JSON(http.StatusOK, gin.H{"message": "Group chat updated successfully"})
}

func GroupChatDelete(context *gin.Context) {
	id := context.Param("id")
	userId, exists := context.Get("userId")
	if !exists {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not provided"})
		return
	}

	// Assurez-vous que userId est du bon type, ici on suppose que c'est un uint
	userID, ok := userId.(uint)
	if !ok {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "User ID is not of type uint"})
		return
	}

	// Vérifier si l'utilisateur est le propriétaire du GroupChat
	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ? AND role = ?", id, userID, "owner").First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this group chat"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Effectuer un soft delete du GroupChat
	result = initializers.DB.Model(&models.GroupChat{}).Where("id = ?", id).Delete(&models.GroupChat{})
	if result.Error != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete group chat"})
		return
	}

	// Vérifier si une suppression a eu lieu
	if result.RowsAffected == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "No group chat found with the given ID or already deleted"})
		return
	}

	// Renvoyer la réponse de succès
	context.JSON(http.StatusOK, gin.H{"message": "Group chat deleted successfully"})
}
