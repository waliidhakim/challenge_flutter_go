package utils

import (
	"log"
	"mime/multipart"

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
