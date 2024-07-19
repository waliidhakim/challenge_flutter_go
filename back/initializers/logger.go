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

// func InitDailyLogger() {
// 	// Déterminer le chemin du répertoire courant
// 	currentDir, err := os.Getwd()
// 	if err != nil {
// 		panic("Failed to get current directory: " + err.Error())
// 	}

// 	logsPath := filepath.Join(currentDir, "logs")
// 	logFilePath := filepath.Join(logsPath, "logs.txt")

// 	// Vérifiez si le répertoire existe, sinon créez-le
// 	if _, err := os.Stat(logsPath); os.IsNotExist(err) {
// 		err = os.MkdirAll(logsPath, os.ModePerm) // os.ModePerm équivaut à 0777
// 		if err != nil {
// 			panic("Failed to create log directory: " + err.Error())
// 		}
// 	}

// 	// Vérifiez si le fichier de log existe, sinon créez-le avec des permissions ouvertes
// 	if _, err := os.Stat(logFilePath); os.IsNotExist(err) {
// 		file, err := os.OpenFile(logFilePath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666) // Crée le fichier avec des permissions de lecture et d'écriture pour tous
// 		if err != nil {
// 			panic("Failed to create log file: " + err.Error())
// 		}
// 		file.Close() // Fermez le fichier immédiatement après la création
// 	}

// 	writeSyncer := zapcore.AddSync(&lumberjack.Logger{
// 		Filename:   logFilePath, // Utilisez le chemin du fichier de log
// 		MaxSize:    10,          // megabytes
// 		MaxBackups: 3,
// 		MaxAge:     28,   // jours
// 		Compress:   true, // compression activée
// 	})

// 	encoderConfig := zap.NewProductionEncoderConfig()
// 	encoderConfig.TimeKey = "timestamp"
// 	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder // Format de la date plus lisible
// 	encoder := zapcore.NewJSONEncoder(encoderConfig)

// 	core := zapcore.NewCore(encoder, writeSyncer, zap.InfoLevel)

// 	zapLogger := zap.New(core)
// 	defer zapLogger.Sync() // Assurez-vous de flusher le buffer à la fin

// 	Logger = zapLogger.Sugar()
// 	Logger.Infoln("Daily Logger initialized")
// }

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
