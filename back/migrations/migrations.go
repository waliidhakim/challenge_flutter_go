package main

import (
	"backend/initializers"
	"backend/models"
)

func init() {
	initializers.InitLogger()
	initializers.LoadEnvVars()
	initializers.DbConnect()
}

func main() {
	err := initializers.DB.AutoMigrate(
		&models.User{},
		&models.GroupChat{},
		&models.GroupChatUser{},
		&models.GroupChatMessage{},
		&models.GroupChatMessageRead{},
		&models.GroupChatActivityParticipation{},
		&models.FeatureFlipped{},
		&models.GroupChatActivityLocation{},
		&models.GroupChatActivityLocationVote{},
		&models.Setting{},
		&models.LogModel{},
	)
	if err != nil {
		initializers.Logger.Errorln("Error while migrating User")
	} else {
		initializers.Logger.Infoln("Migration successful")
	}
}
