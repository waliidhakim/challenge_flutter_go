package models

import "gorm.io/gorm"

type GroupChatMessageRead struct {
	gorm.Model
	User             User
	GroupChatMessage GroupChatMessage
}
