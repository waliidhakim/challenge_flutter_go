package models

import "gorm.io/gorm"

type FeatureFlipped struct {
	gorm.Model
	FeatureName string
	IsActive    bool `gorm:"not null;default:null"`
}
