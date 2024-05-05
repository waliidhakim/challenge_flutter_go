package models

import "gorm.io/gorm"

type GroupChatUser struct {
	gorm.Model
	GroupChat GroupChat
	User      User
	Role      string
}
