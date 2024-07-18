package initializers

import (
	"backend/models"
	"io"
	"path/filepath"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gorm.io/gorm"
)

var Logger *zap.SugaredLogger
var DbLogger *zap.SugaredLogger

var db *gorm.DB

func InitLogger() {
	zapLogger := zap.NewExample()
	defer zapLogger.Sync()
	Logger = zapLogger.Sugar()
	Logger.Infoln("Logger initialized !!")

	logsPath := "../logs/"
	absPath, _ := filepath.Abs(logsPath)
	Logger.Infof("Logging to %s", absPath)
}

func InitDbLogger(database *gorm.DB) {
	db = database
	if db == nil {
		Logger.Errorln("Database connection is nil")
		return
	}

	Logger.Infoln("Initializing DbLogger with database connection")

	// Utiliser ioutil.Discard pour éviter l'écriture dans un fichier
	w := zapcore.AddSync(io.Discard)

	core := zapcore.NewCore(
		zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig()),
		w,
		zap.InfoLevel,
	)

	// Créer un core personnalisé qui enregistre les logs en base de données
	coreWithDB := zapcore.RegisterHooks(core, func(entry zapcore.Entry) error {
		log := models.LogModel{
			LogLevel:     entry.Level.String(),
			LogMessage:   entry.Message,
			CreationDate: time.Now(),
		}
		if db == nil {
			Logger.Errorln("Database connection is nil when trying to save log")
			return nil
		}
		return log.Save(db)
	})

	logger := zap.New(coreWithDB, zap.AddCaller())
	DbLogger = logger.Sugar()
	DbLogger.Infoln("---DB Logger initialized----")
	Logger.Infoln("DbLogger successfully initialized")
}
