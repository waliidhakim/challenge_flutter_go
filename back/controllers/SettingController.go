package controllers

import (
	"backend/initializers"
	"backend/models"
	"backend/utils"
	"github.com/gin-gonic/gin"
	"net/http"
)

func SettingGet(context *gin.Context) {
	if !utils.IsAdmin(context) {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var settings []models.Setting
	initializers.DB.Find(&settings)
	context.JSON(http.StatusOK, settings)
}

func SettingGetByUserId(context *gin.Context) {
	id := context.Param("id")
	if !utils.IsAdminOrAccountOwner(context, id) {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var setting models.Setting
	initializers.DB.First(&setting, "user_id = ?", id)
	context.JSON(http.StatusOK, setting)
}

func SettingPost(context *gin.Context) {
	if !utils.IsAdmin(context) {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var body struct {
		UserId          int
		NotifyLevel     models.NotifyLevel
		NotifyThreshold int
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST Setting : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	setting := models.Setting{
		UserID:          body.UserId,
		NotifyLevel:     body.NotifyLevel,
		NotifyThreshold: body.NotifyThreshold,
	}
	initializers.DB.Create(&setting)
	context.JSON(http.StatusCreated, setting)
}

func SettingUpdate(context *gin.Context) {
	id := context.Param("id")
	if !utils.IsAdminOrAccountOwner(context, id) {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var body struct {
		NotifyLevel     models.NotifyLevel
		NotifyThreshold int
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("PATCH Setting : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}
	var setting models.Setting
	initializers.DB.First(&setting, id)
	initializers.DB.Model(&setting).Updates(models.Setting{
		NotifyLevel:     body.NotifyLevel,
		NotifyThreshold: body.NotifyThreshold,
	})
	context.JSON(http.StatusOK, setting)
}

func SettingDelete(context *gin.Context) {
	if !utils.IsAdmin(context) {
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	id := context.Param("id")
	initializers.DB.Delete(&models.Setting{}, id)
	context.Status(http.StatusOK)
}
