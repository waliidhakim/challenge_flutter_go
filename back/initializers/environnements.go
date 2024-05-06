package initializers

import (
	"github.com/joho/godotenv"
)

func LoadEnvVars() {
	err := godotenv.Load()
	if err != nil {
		Logger.Fatalln("Error loading .env file")
	}
}
