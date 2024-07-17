package models

import (
	"gorm.io/gorm"
	"time"
)

type GroupChatActivityParticipation struct {
	gorm.Model
	UserID            uint `gorm:"foreignKey:UserID"`
	GroupChatID       int  `gorm:"foreignKey:GroupChatID"`
	ParticipationDate time.Time
}
