package models

import (
	"time"

	"gorm.io/gorm"
)

type GroupChat struct {
	gorm.Model
	Name        string
	Activity    string
	CatchPhrase string
	Alert       string
	ImageUrl    string
	AlertDate   time.Time

	Users []GroupChatUser `gorm:"foreignKey:GroupChatID"`
}
