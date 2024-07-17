package controllers

import (
	"backend/initializers"
	"backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// FeaturesList - List all features
func FeaturesList(c *gin.Context) {
	var features []models.FeatureFlipped
	result := initializers.DB.Find(&features)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusOK, features)
}

// FeatureCreate - Create a feature
func FeatureCreate(c *gin.Context) {
	var feature models.FeatureFlipped
	if err := c.ShouldBindJSON(&feature); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	result := initializers.DB.Create(&feature)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusCreated, feature)
}

// FeatureGet - Get a single feature
func FeatureGet(c *gin.Context) {
	var feature models.FeatureFlipped
	if err := initializers.DB.Where("id = ?", c.Param("id")).First(&feature).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Feature not found"})
		return
	}
	c.JSON(http.StatusOK, feature)
}

// FeatureUpdate - Update a feature
func FeatureUpdate(c *gin.Context) {
	var feature models.FeatureFlipped
	if err := initializers.DB.Where("id = ?", c.Param("id")).First(&feature).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Feature not found"})
		return
	}

	if err := c.ShouldBindJSON(&feature); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	initializers.DB.Save(&feature)
	c.JSON(http.StatusOK, feature)
}

// FeatureDelete - Delete a feature
func FeatureDelete(c *gin.Context) {
	if err := initializers.DB.Delete(&models.FeatureFlipped{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Feature deleted"})
}
