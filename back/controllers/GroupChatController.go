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

// GroupChatGet godoc
// @Summary Get group chats
// @Description Retrieves group chats associated with the authenticated user or all if admin
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} swaggermodels.GroupChatSwagger "List of group chats"
// @Router /group-chat [get]
func GroupChatGet(context *gin.Context) {
	fmt.Println("get groupchats")
	var groupChats = services.GetGroupChats(context)
	context.JSON(http.StatusOK, groupChats)

}

<<<<<<< Updated upstream
// GroupChatGetAll godoc
// @Summary Get all group chats
// @Description Retrieves all group chats from the database
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} swaggermodels.GroupChatSwagger "Complete list of all group chats"
// @Router /group-chat/all [get]
func GroupChatGetAll(context *gin.Context) {
	fmt.Println("get all db groupchats")
	var allGroupChats = services.GetAllGroupChats(context)
	context.JSON(http.StatusOK, allGroupChats)

}

// GroupChatPost godoc
// @Summary Create a group chat
// @Description Creates a new group chat with optional image upload
// @Tags group-chat
// @Accept multipart/form-data
// @Produce json
// @Security ApiKeyAuth
// @Param name formData string true "Name of the group chat"
// @Param activity formData string true "Activity associated with the group chat"
// @Param catchPhrase formData string false "Catchphrase of the group chat"
// @Param avatar formData file false "Upload image for the group chat"
// @Success 201 {object} swaggermodels.GroupChatSwagger "Group chat created successfully"
// @Failure 400 {object} map[string]string "Invalid input data"
// @Failure 403 {string} string "Feature not available"
// @Failure 500 {string} string "Internal server error"
// @Router /group-chat [post]
=======
>>>>>>> Stashed changes
func GroupChatPost(context *gin.Context) {

	isActive, errFeatureFlipping := utils.IsFeatureActive(initializers.DB, "GroupChatCreation")
	if errFeatureFlipping != nil {
		initializers.Logger.Errorln("Error checking feature availability:", errFeatureFlipping)
		context.Status(http.StatusInternalServerError)
		return
	}
	if !isActive {
		context.JSON(http.StatusForbidden, gin.H{
			"error": "La création de group chat est actuellement désactivée. Veuillez réessayer plus tard.",
		})
		return
	}

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

// GroupChatUpdate godoc
// @Summary Update group chat
// @Description Updates an existing group chat; admin or owner can add new members
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Group Chat ID"
// @Param name body string false "Name of the group chat"
// @Param activity body string false "Activity associated with the group chat"
// @Param catchPhrase body string false "Catchphrase of the group chat"
// @Success 200 {string} string "Group chat updated successfully"
// @Failure 400 {string} string "Invalid input data"
// @Failure 401 {string} string "Unauthorized access"
// @Failure 403 {string} string "Forbidden operation, not an owner/admin"
// @Failure 500 {string} string "Internal server error"
// @Router /group-chat/{id} [patch]
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

<<<<<<< Updated upstream
	if err := utils.IsGroupChatOwner(context, groupChatId, userID); err != nil {
		context.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
=======
	groupChat := &models.GroupChat{}
	initializers.DB.First(&groupChat, grouChatId)

	// Mise à jour du GroupChat
	update := initializers.DB.Model(&models.GroupChat{}).Where("id = ?", grouChatId).Updates(models.GroupChat{
		Name:        updateData.Name,
		Activity:    updateData.Activity,
		CatchPhrase: updateData.CatchPhrase,
	})
	if update.Error != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update group chat"})
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
	if err := utils.AddNewMembers(context, uint(groupChatIdAsUint), updateData.NewMembers); err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
=======
	// Ajouter les nouveaux membres
	for _, phone := range updateData.NewMembers {
		var user models.User
		if err := initializers.DB.Where("phone = ?", phone).First(&user).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				context.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("User with phone %s not found", phone)})
				return
			}
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		groupChatUser := models.GroupChatUser{
			GroupChatID: grouChatIdAsUint,
			UserID:      user.ID,
			Role:        "member",
		}
		if err := initializers.DB.Create(&groupChatUser).Error; err != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add member to group chat"})
			return
		}
		fmt.Println(groupChat)
		fmt.Println(groupChat.Name)
		fmt.Println(groupChat.ImageUrl)
		notif := models.Notification{
			UserID:           user.ID,
			GroupId:          int(grouChatIdAsUint),
			Title:            "Vous avez été ajouté à " + groupChat.Name,
			NotificationIcon: groupChat.ImageUrl,
			DateTime:         time.Now(),
			GroupName:        groupChat.Name,
		}
		if err := initializers.DB.Create(&notif).Error; err != nil {
			context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create notification"})
			initializers.Logger.Errorln("Failed to create notification:", err)
			continue
		}
		fmt.Println(notif)
		fmt.Println("Notification created")
	}

	// Renvoyer la réponse
	if update.RowsAffected == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "No group chat found with the given ID"})
>>>>>>> Stashed changes
		return
	}

	context.JSON(http.StatusOK, gin.H{"message": "Group chat updated successfully"})
}

// GroupChatDelete godoc
// @Summary Delete group chat
// @Description Deletes a group chat, operation allowed only for the owner
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Group Chat ID"
// @Success 200 {string} string "Group chat deleted successfully"
// @Failure 401 {string} string "Unauthorized access"
// @Failure 403 {string} string "Not the owner"
// @Failure 404 {string} string "Group chat not found"
// @Router /group-chat/{id} [delete]
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

// GroupChatUpdateInfos godoc
// @Summary Update group chat information
// @Description Updates specific information of a group chat by the owner
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Group Chat ID"
// @Param name formData string false "New name of the group chat"
// @Param activity formData string false "New activity of the group chat"
// @Param catchPhrase formData string false "New catchphrase of the group chat"
// @Param image formData file false "New image for the group chat"
// @Success 200 {string} string "Group chat information updated successfully"
// @Failure 401 {string} string "Unauthorized access"
// @Failure 403 {string} string "Not the owner"
// @Failure 404 {string} string "Group chat not found"
// @Failure 500 {string} string "Failed to update group chat information"
// @Router /group-chat/infos/{id} [patch]
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

// GroupChatGetById godoc
// @Summary Retrieve a specific group chat by ID
// @Description Retrieves detailed information about a specific group chat, including its members, based on the user's role and permissions.
// @Tags group-chat
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Group Chat ID"
// @Success 200 {object} swaggermodels.GroupChatSwagger "Detailed information of the group chat including members"
// @Failure 401 {string} string "Unauthorized if user ID is not provided or user is not authenticated"
// @Failure 403 {string} string "Forbidden if user is neither an admin nor a member/owner of the group chat"
// @Failure 404 {string} string "Not Found if the group chat does not exist"
// @Failure 500 {string} string "Internal server error if there are database errors"
// @Router /group-chat/{id} [get]
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
