package models

import (
	"gorm.io/gorm"
)

type GroupChatActivityLocation struct {
	gorm.Model
	Name      string
	Address   string
	Lat       string
	Long      string
	GroupChat GroupChat
}
