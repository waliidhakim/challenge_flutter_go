package models

import "gorm.io/gorm"

type GroupChatMessage struct {
	gorm.Model
	Message     string
	UserID      uint
	User        User `gorm:"foreignKey:UserID"`
	GroupChatID uint
	GroupChat   GroupChat `gorm:"foreignKey:GroupChatID"`
}
