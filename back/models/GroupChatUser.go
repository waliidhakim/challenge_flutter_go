package models

import "gorm.io/gorm"

type GroupChatUser struct {
	gorm.Model
	// GroupChat   GroupChat
	GroupChatID uint `gorm:"foreignKey:GroupChatID"`
	// User        User
	UserID uint `gorm:"foreignKey:UserID"`
	Role   string
}
