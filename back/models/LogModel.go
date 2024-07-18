package models

import (
	"time"

	"gorm.io/gorm"
)

type LogModel struct {
	gorm.Model
	LogLevel     string
	LogMessage   string
	CreationDate time.Time
}

func (log LogModel) Save(db *gorm.DB) error {
	return db.Create(&log).Error
}
