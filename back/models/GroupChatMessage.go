package models

import "gorm.io/gorm"

type GroupChatMessage struct {
	gorm.Model
	Message string
	User    User
}
