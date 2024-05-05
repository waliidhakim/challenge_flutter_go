package models

import (
	"gorm.io/gorm"
	"time"
)

type GroupChatActivityParticipation struct {
	gorm.Model
	User              User
	GroupChat         GroupChat
	ParticipationDate time.Time
}
