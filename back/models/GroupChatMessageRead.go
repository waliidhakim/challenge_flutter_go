package models

import (
	"time"

	"gorm.io/gorm"
)

type GroupChatMessageRead struct {
	gorm.Model
	UserID             uint
	User               User `gorm:"foreignKey:UserID"`
	GroupChatMessageID uint
	GroupChatMessage   GroupChatMessage `gorm:"foreignKey:GroupChatMessageID"`
	GroupChatID        uint
	GroupChat          GroupChat  `gorm:"foreignKey:GroupChatID"`
	ReadAt             *time.Time `gorm:"default:null"`
}
