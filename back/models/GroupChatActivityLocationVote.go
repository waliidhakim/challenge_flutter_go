package models

import (
	"gorm.io/gorm"
	"time"
)

type GroupChatActivityLocationVote struct {
	gorm.Model
	LocationId int  `gorm:"foreignKey:LocationID"`
	UserId     uint `gorm:"foreignKey:UserID"`
	GroupId    int  `gorm:"foreignKey:GroupID"`
	VoteDate   time.Time
}
