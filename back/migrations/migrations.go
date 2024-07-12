package main

import (
	"backend/initializers"
	"backend/models"
)

func init() {
	initializers.LoadEnvVars()
	initializers.InitLogger()
	initializers.DbConnect()
}

func main() {
	err := initializers.DB.AutoMigrate(&models.User{}, &models.GroupChat{}, &models.GroupChatUser{}, &models.GroupChatMessage{}, &models.GroupChatMessageRead{}, &models.Setting{})
	if err != nil {
		initializers.Logger.Errorln("Error while migrating User")
	} else {
		initializers.Logger.Infoln("Migration successful")
	}
}
