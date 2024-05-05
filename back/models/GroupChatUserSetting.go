package models

import "gorm.io/gorm"

type GroupChatUserSetting struct {
	gorm.Model
	NotifyLevel     int
	NotifyThreshold int
	User            User
	GroupChat       GroupChat
}
