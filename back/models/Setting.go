package models

import "gorm.io/gorm"

type NotifyLevel string

const (
	All     NotifyLevel = "all"
	Partial NotifyLevel = "partial"
	None    NotifyLevel = "none"
)

type Setting struct {
	gorm.Model
	NotifyLevel     NotifyLevel
	NotifyThreshold int
	UserID          int `gorm:"foreignKey:UserID"`
}
