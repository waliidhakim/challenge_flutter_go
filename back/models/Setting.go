package models

import "gorm.io/gorm"

type Setting struct {
	gorm.Model
	NotifyLevel     int
	NotifyThreshold int
	User            User
}
