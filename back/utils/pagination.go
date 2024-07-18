package utils

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

// PaginationParams contient les paramètres de pagination
type PaginationParams struct {
	Page     int
	PageSize int
	Offset   int
}

// GetPaginationParams extrait les paramètres de pagination de la requête
func GetPaginationParams(c *gin.Context) PaginationParams {
	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("pageSize", "10")

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}

	pageSize, err := strconv.Atoi(pageSizeStr)
	if err != nil || pageSize < 1 {
		pageSize = 10
	}

	offset := (page - 1) * pageSize

	return PaginationParams{
		Page:     page,
		PageSize: pageSize,
		Offset:   offset,
	}
}
