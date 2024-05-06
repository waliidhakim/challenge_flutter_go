package initializers

import (
	"go.uber.org/zap"
)

var Logger *zap.SugaredLogger

func InitLogger() {
	zapLogger := zap.NewExample()
	defer zapLogger.Sync()
	Logger = zapLogger.Sugar()
	Logger.Infoln("Logger initialized")
}
