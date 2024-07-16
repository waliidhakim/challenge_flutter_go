package controllers

import (
	"backend/initializers"
	"backend/models"
	"backend/services"
	roleCheck "backend/utils"
	utils "backend/utils"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func GroupChatGet(context *gin.Context) {
	fmt.Println("get groupchats")
	var groupChats = services.GetGroupChats(context)
	context.JSON(http.StatusOK, groupChats)

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

	// Réception du fichier
	file, err := context.FormFile("avatar")
	var imageUrl string
	if err == nil {
		imageUrl, err = utils.UploadImageToS3(*file, "group-chats")
		if err != nil {
			context.Status(http.StatusInternalServerError)
			return
		}
	}

	groupChat := models.GroupChat{
		Name:        body.Name,
		Activity:    body.Activity,
		CatchPhrase: body.CatchPhrase,
		ImageUrl:    imageUrl,
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
	groupChatId := context.Param("id")

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

	var updateData models.UpdateGroupChatData
	if err := context.BindJSON(&updateData); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data"})
		return
	}

	if utils.IsAdmin(context) {
		if err := utils.UpdateGroupChat(context, groupChatId, updateData); err != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		groupChatIdAsUint, err := strconv.ParseUint(groupChatId, 10, 32)
		if err != nil {
			fmt.Println(err)
		}

		if err := utils.AddNewMembers(context, uint(groupChatIdAsUint), updateData.NewMembers); err != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		context.JSON(http.StatusOK, gin.H{"message": "Group chat updated successfully"})
		return
	}

	if err := utils.IsGroupChatOwner(context, groupChatId, userID); err != nil {
		context.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
		return
	}

	if err := utils.UpdateGroupChat(context, groupChatId, updateData); err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	groupChatIdAsUint, err := strconv.ParseUint(groupChatId, 10, 32)
	if err != nil {
		fmt.Println(err)
	}

	if err := utils.AddNewMembers(context, uint(groupChatIdAsUint), updateData.NewMembers); err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
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

func GroupChatGetMessages(c *gin.Context) {
	groupId := c.Param("id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "40"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	var messages []models.GroupChatMessage
	result := initializers.DB.Preload("User").Where("group_chat_id = ?", groupId).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&messages)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load messages"})
		return
	}

	simplifiedMessages := []map[string]interface{}{}
	for _, msg := range messages {
		simplifiedMessages = append(simplifiedMessages, map[string]interface{}{
			"sender_id":  msg.UserID,
			"username":   msg.User.Username,
			"message":    msg.Message,
			"created_at": msg.CreatedAt.Format(time.RFC3339), // Ajoutez l'heure de création ici
		})
	}

	fmt.Println("simplified messages")

	c.JSON(http.StatusOK, simplifiedMessages)
}

func GroupChatUpdateInfos(context *gin.Context) {
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

	var updateData struct {
		Name        string `form:"name"`
		Activity    string `form:"activity"`
		CatchPhrase string `form:"catchPhrase"`
	}
	if err := context.Bind(&updateData); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data"})
		return
	}

	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ? AND role = ?", grouChatId, userID, "owner").First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this group chat"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	var groupChat models.GroupChat
	update := initializers.DB.Model(&groupChat).Where("id = ?", grouChatId).Updates(models.GroupChat{
		Name:        updateData.Name,
		Activity:    updateData.Activity,
		CatchPhrase: updateData.CatchPhrase,
	})
	if update.Error != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update group chat"})
		return
	}

	file, err := context.FormFile("image")
	if err == nil {
		imageUrl, err := utils.UploadImageToS3(*file, "group-chats")
		if err != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload image"})
			return
		}
		update = initializers.DB.Model(&groupChat).Where("id = ?", grouChatId).Update("image_url", imageUrl)
		if update.Error != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update image URL"})
			return
		}
	}

	if update.RowsAffected == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "No group chat found with the given ID"})
		return
	}
	context.JSON(http.StatusOK, gin.H{"message": "Group chat updated successfully"})
}

func GroupChatGetById(context *gin.Context) {
	groupChatId := context.Param("id")
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

	var groupChat models.GroupChat

	// Vérifier si le user est un admin (bypass la vérification si oui)
	if roleCheck.IsAdmin(context) {
		result := initializers.DB.Preload("Users.User").First(&groupChat, groupChatId)
		if result.Error != nil {
			if errors.Is(result.Error, gorm.ErrRecordNotFound) {
				context.JSON(http.StatusNotFound, gin.H{"error": "Group chat not found"})
				return
			}
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error when retrieving group chat"})
			return
		}

		context.JSON(http.StatusOK, groupChat)
		return
	}

	// Vérification des droits d'accès pour les utilisateurs non-admin
	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ?", groupChatId, userID).First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusForbidden, gin.H{"error": "Access to the specified group chat is forbidden or group chat does not exist"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	result = initializers.DB.Preload("Users.User").First(&groupChat, groupChatId)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusNotFound, gin.H{"error": "Group chat not found"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error when retrieving group chat"})
		return
	}

	context.JSON(http.StatusOK, groupChat)
}
