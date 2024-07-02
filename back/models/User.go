package models

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Firstname string
	Lastname  string
	Username  string
	Password  string
	AvatarUrl string
	Role      string
	Phone     string `gorm:"unique"`

	GroupChats []GroupChatUser `gorm:"foreignKey:UserID"`
}
