package utils

import (
	"backend/initializers"
	"backend/models"
	"errors"
	"fmt"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Mettre à jour le GroupChat
func UpdateGroupChat(context *gin.Context, groupChatId string, updateData models.UpdateGroupChatData) error {
	update := initializers.DB.Model(&models.GroupChat{}).Where("id = ?", groupChatId).Updates(models.GroupChat{
		Name:        updateData.Name,
		Activity:    updateData.Activity,
		CatchPhrase: updateData.CatchPhrase,
	})
	if update.Error != nil {
		return errors.New("Failed to update group chat")
	}
	if update.RowsAffected == 0 {
		return errors.New("No group chat found with the given ID")
	}
	return nil
}

// Ajouter de nouveaux membres
func AddNewMembers(context *gin.Context, groupChatIdAsUint uint, newMembers []string) error {
	// Filtrer les numéros de téléphone vides
	validPhones := []string{}
	for _, phone := range newMembers {
		if phone != "" {
			validPhones = append(validPhones, phone)
		}
	}

	if len(validPhones) > 0 {
		for _, phone := range validPhones {
			var user models.User
			if err := initializers.DB.Where("phone = ?", phone).First(&user).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					return fmt.Errorf("User with phone %s not found", phone)
				}
				return errors.New("Database error")
			}

			groupChatUser := models.GroupChatUser{
				GroupChatID: groupChatIdAsUint,
				UserID:      user.ID,
				Role:        "member",
			}
			if err := initializers.DB.Create(&groupChatUser).Error; err != nil {
				return errors.New("Failed to add member to group chat")
			}
		}
	}
	return nil
}

func IsGroupChatOwner(context *gin.Context, groupChatId string, userID uint) error {
	var groupChatUser models.GroupChatUser
	result := initializers.DB.Where("group_chat_id = ? AND user_id = ? AND role = ?", groupChatId, userID, "owner").First(&groupChatUser)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return errors.New("You are not the owner of this group chat")
		}
		return errors.New("Database error")
	}
	return nil
}
