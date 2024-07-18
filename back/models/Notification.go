package models

import (
	"time"

	"gorm.io/gorm"
)

type Notification struct {
	gorm.Model
	Title            string
	NotificationIcon string
	DateTime         time.Time
	GroupName        string
	Content          string
	UserID           uint `gorm:"foreignKey:UserID"`
	GroupId          int  `gorm:"foreignKey:GroupID"`
}
