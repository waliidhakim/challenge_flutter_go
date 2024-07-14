package models

import (
	"time"

	"gorm.io/gorm"
)

type GroupChatActivityParticipation struct {
	gorm.Model
	// User              User
	UserID uint `gorm:"foreignKey:UserID"`
	// GroupChat         GroupChat
	GroupChatID       uint `gorm:"foreignKey:GroupChatID"`
	ParticipationDate time.Time
}
