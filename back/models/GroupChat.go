package models

import (
	"time"

	"gorm.io/gorm"
)

type GroupChat struct {
	gorm.Model
	Name        string
	Activity    string
	CatchPhrase string
	Alert       string
	ImageUrl    string
	AlertDate   time.Time

	Users    []GroupChatUser    `gorm:"foreignKey:GroupChatID"`
	Messages []GroupChatMessage `gorm:"foreignKey:GroupChatID"`
}

// GetUsers retrieves the users of a group chat
func (gc *GroupChat) GetUsers(db *gorm.DB) ([]User, error) {
	var users []User
	err := db.Table("users").
		Joins("JOIN group_chat_users ON group_chat_users.user_id = users.id").
		Where("group_chat_users.group_chat_id = ?", gc.ID).
		Find(&users).Error
	return users, err
}
