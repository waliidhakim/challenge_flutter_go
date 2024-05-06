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
	err := initializers.DB.AutoMigrate(&models.User{})
	if err != nil {
		initializers.Logger.Errorln("Error while migrating User")
	} else {
		initializers.Logger.Infoln("Migration successful")
	}
}
