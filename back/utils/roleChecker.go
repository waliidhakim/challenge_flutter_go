package roleCheck

import (
	roles "backend/constants"
	"backend/initializers"
	"backend/models"
	"github.com/gin-gonic/gin"
)

func IsAdmin(context *gin.Context) bool {
	userId, _ := context.Get("userId")
	var user models.User
	initializers.DB.First(&user, userId)
	if user.Role == roles.Admin {
		return true
	}
	return false
}

func IsAccountOwner(context *gin.Context, userId interface{}) bool {
	initializers.Logger.Infoln(userId)
	contextUserId, _ := context.Get("userId")
	var user models.User
	initializers.DB.First(&user, userId)
	if user.ID == contextUserId {
		return true
	}
	return false
}

func IsAdminOrAccountOwner(context *gin.Context, userId interface{}) bool {
	if IsAdmin(context) || IsAccountOwner(context, userId) {
		return true
	}
	return false
}
