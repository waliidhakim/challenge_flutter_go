package models

import (
	"gorm.io/gorm"
	"time"
)

type GroupChat struct {
	gorm.Model
	Name        string
	Activity    string
	CatchPhrase string
	Alert       string
	AlertDate   time.Time
}
