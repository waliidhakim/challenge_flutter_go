package utils

import (
	"log"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

// UploadImageToS3 uploads an image to an AWS S3 bucket and returns the URL
func UploadImageToS3(file multipart.FileHeader, directory string) (string, error) {
	// Créer une session AWS
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("eu-central-1"),
	})
	if err != nil {
		log.Println("Error creating AWS session:", err)
		return "", err
	}

	// Créer un uploader avec la session
	uploader := s3manager.NewUploader(sess)

	// Ouvrir le fichier
	src, err := file.Open()
	if err != nil {
		log.Println("Error opening file:", err)
		return "", err
	}
	defer src.Close()

	// Uploader le fichier
	uploadOutput, err := uploader.Upload(&s3manager.UploadInput{
		Bucket: aws.String("challange-esgi"),
		Key:    aws.String(directory + "/" + file.Filename),
		Body:   src,
	})
	if err != nil {
		log.Println("Failed to upload file to S3:", err)
		return "", err
	}

	return uploadOutput.Location, nil
}

func UploadLogsEveryTenSeconds() {
	currentDir, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to get current directory: %v", err)
	}
	logsPath := filepath.Join(currentDir, "logs", "logs.txt")

	for {
		time.Sleep(10 * time.Second)

		log.Printf("Attempting to open log file at: %v", logsPath)

		file, err := os.Open(logsPath)
		if err != nil {
			log.Printf("Error opening log file at %v. Error: %v", logsPath, err)
			continue
		}

		fileInfo, err := file.Stat()
		if err != nil {
			log.Printf("Error getting file info: %v", err)
			file.Close()
			continue
		}

		fileHeader := multipart.FileHeader{
			Filename: fileInfo.Name(),
			Size:     fileInfo.Size(),
		}

		_, err = UploadImageToS3(fileHeader, "logs-directory/"+fileInfo.Name())
		if err != nil {
			log.Printf("Failed to upload log file: %v", err)
		}

		file.Close()
	}
}
