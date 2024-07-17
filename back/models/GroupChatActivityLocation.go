package models

import (
	"gorm.io/gorm"
)

type GroupChatActivityLocation struct {
	gorm.Model
	Name        string
	Address     string
	GroupChatID int `gorm:"foreignKey:GroupChatID"`
}
