package utils

import (
	"backend/models"

	"gorm.io/gorm"
)

// IsFeatureActive vérifie si une fonctionnalité spécifique est active.
func IsFeatureActive(db *gorm.DB, featureName string) (bool, error) {
	var feature models.FeatureFlipped
	if err := db.Where("feature_name = ?", featureName).First(&feature).Error; err != nil {
		return false, err
	}
	return feature.IsActive, nil
}
