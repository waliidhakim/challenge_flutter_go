package models

import (
	"gorm.io/gorm"
	"time"
)

type GroupChatActivityLocationVote struct {
	gorm.Model
	Location GroupChatActivityLocation
	User     User
	VoteDate time.Time
}
