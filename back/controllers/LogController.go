package controllers

import (
	"backend/initializers"
	"backend/models"
	roleCheck "backend/utils"
	utils "backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetLogs godoc
// @Summary Get logs
// @Description Retrieves logs with pagination
// @Tags logs
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param page query int false "Page number" default(1)
// @Param pageSize query int false "Number of logs per page" default(10)
// @Success 200 {object} swaggermodels.LogPaginationResponseSwagger "Paginated logs response"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 500 {string} string "Internal server error on fetching logs"
// @Router /logs [get]
func GetLogs(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	// Utiliser la fonction utilitaire pour obtenir les paramètres de pagination
	pagination := utils.GetPaginationParams(c)

	var logs []models.LogModel
	if err := initializers.DB.Offset(pagination.Offset).Limit(pagination.PageSize).Find(&logs).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch logs"})
		return
	}

	// Récupérer le nombre total de logs
	var totalLogs int64
	if err := initializers.DB.Model(&models.LogModel{}).Count(&totalLogs).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to count logs"})
		return
	}

	// Calculer le nombre total de pages
	totalPages := (totalLogs + int64(pagination.PageSize) - 1) / int64(pagination.PageSize)

	// Retourner les résultats avec pagination
	c.JSON(http.StatusOK, gin.H{
		"logs":        logs,
		"totalLogs":   totalLogs,
		"totalPages":  totalPages,
		"currentPage": pagination.Page,
		"pageSize":    pagination.PageSize,
	})
}

// GetLogsByLevel godoc
// @Summary Get logs by level
// @Description Retrieves logs of a specific level with pagination
// @Tags logs
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param level path string true "Log level to filter by"
// @Param page query int false "Page number" default(1)
// @Param pageSize query int false "Number of logs per page" default(10)
// @Success 200 {object} swaggermodels.LogPaginationResponseSwagger "Paginated logs response filtered by level"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 500 {string} string "Internal server error on fetching logs"
// @Router /logs/level/{level} [get]
func GetLogsByLevel(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	level := c.Param("level")

	// Utiliser la fonction utilitaire pour obtenir les paramètres de pagination
	pagination := utils.GetPaginationParams(c)

	var logs []models.LogModel
	if err := initializers.DB.Where("log_level = ?", level).Offset(pagination.Offset).Limit(pagination.PageSize).Find(&logs).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch logs"})
		return
	}

	// Récupérer le nombre total de logs pour ce niveau
	var totalLogs int64
	if err := initializers.DB.Model(&models.LogModel{}).Where("log_level = ?", level).Count(&totalLogs).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to count logs"})
		return
	}

	// Calculer le nombre total de pages
	totalPages := (totalLogs + int64(pagination.PageSize) - 1) / int64(pagination.PageSize)

	// Retourner les résultats avec pagination
	c.JSON(http.StatusOK, gin.H{
		"logs":        logs,
		"totalLogs":   totalLogs,
		"totalPages":  totalPages,
		"currentPage": pagination.Page,
		"pageSize":    pagination.PageSize,
	})
}

// GetLogByID godoc
// @Summary Get log by ID
// @Description Retrieves a specific log by its ID
// @Tags logs
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "Log ID"
// @Success 200 {object} swaggermodels.LogPaginationResponseSwagger "Detailed log information"
// @Failure 401 {string} string "Unauthorized if not admin"
// @Failure 404 {string} string "Log not found"
// @Router /logs/{id} [get]
func GetLogByID(c *gin.Context) {
	id := c.Param("id")

	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	var log models.LogModel
	if err := initializers.DB.First(&log, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Log not found"})
		return
	}
	c.JSON(http.StatusOK, log)
}
