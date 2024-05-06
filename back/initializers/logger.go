package initializers

import (
	"go.uber.org/zap"
	"log"
)

var Logger *zap.SugaredLogger

func InitLogger() {
	zapLogger := zap.NewExample()
	defer func(zapLogger *zap.Logger) {
		err := zapLogger.Sync()
		if err != nil {
			log.Println("Error while initializing logger")
		}
	}(zapLogger)
	Logger = zapLogger.Sugar()
}
