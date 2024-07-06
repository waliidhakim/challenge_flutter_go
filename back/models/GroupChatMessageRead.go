package models

import "gorm.io/gorm"

type GroupChatMessageRead struct {
	gorm.Model
	UserID             uint
	User               User `gorm:"foreignKey:UserID"`
	GroupChatMessageID uint
	GroupChatMessage   GroupChatMessage `gorm:"foreignKey:GroupChatMessageID"`
}
