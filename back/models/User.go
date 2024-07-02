package models

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Firstname  string
	Lastname   string
	Username   string
	Password   string `gorm:"not null;default:null"`
	AvatarUrl  string
	Role       string
	Phone      string `gorm:"unique; not null;default:null"`
	Onboarding bool   `gorm:"default:true"`
}
