package controllers

import (
	"backend/initializers"
	"backend/models"
	roleCheck "backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

// FeaturesList godoc
// @Summary List features
// @Description Retrieves a list of all feature toggles
// @Tags features
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {array} swaggermodels.FeatureFlippedSwagger "List of features"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 500 {string} string "Internal server error on fetching features"
// @Router /features [get]
func FeaturesList(c *gin.Context) {

	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	var features []models.FeatureFlipped
	result := initializers.DB.Find(&features)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusOK, features)
}

// FeatureCreate godoc
// @Summary Create feature
// @Description Creates a new feature toggle
// @Tags features
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param feature body swaggermodels.FeatureFlippedSwagger true "Feature to create"
// @Success 201 {object} swaggermodels.FeatureFlippedSwagger "Feature created"
// @Failure 400 {string} string "Bad request if data is incorrect"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 500 {string} string "Internal server error on creating feature"
// @Router /features [post]
func FeatureCreate(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

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

// FeatureGet godoc
// @Summary Get feature
// @Description Retrieves a specific feature by ID
// @Tags features
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Feature ID"
// @Success 200 {object} swaggermodels.FeatureFlippedSwagger "Feature retrieved"
// @Failure 404 {string} string "Feature not found"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Router /features/{id} [get]
func FeatureGet(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	var feature models.FeatureFlipped
	if err := initializers.DB.Where("id = ?", c.Param("id")).First(&feature).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Feature not found"})
		return
	}
	c.JSON(http.StatusOK, feature)
}

// FeatureUpdate godoc
// @Summary Update feature
// @Description Updates an existing feature toggle
// @Tags features
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Feature ID"
// @Param feature body swaggermodels.FeatureFlippedSwagger true "Feature data to update"
// @Success 200 {object} swaggermodels.FeatureFlippedSwagger "Feature updated"
// @Failure 400 {string} string "Bad request if data is incorrect"
// @Failure 404 {string} string "Feature not found"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Router /features/{id} [patch]
func FeatureUpdate(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

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

// FeatureDelete godoc
// @Summary Delete feature
// @Description Deletes a specific feature toggle
// @Tags features
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Feature ID"
// @Success 200 {string} string "Feature deleted"
// @Failure 404 {string} string "Feature not found"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 500 {string} string "Internal server error on deleting feature"
// @Router /features/{id} [delete]
func FeatureDelete(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	if err := initializers.DB.Delete(&models.FeatureFlipped{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Feature deleted"})
}
