package controllers

import (
	"backend/models"
	"context"
	"net/http"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/gin-gonic/gin"
	"google.golang.org/api/option"
)

var firebaseApp *firebase.App
var messagingClient *messaging.Client

func InitFirebase() {
	opt := option.WithCredentialsFile("./serviceAccountKey.json")
	var err error
	firebaseApp, err = firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		panic("Error initializing Firebase app: " + err.Error())
	}

	messagingClient, err = firebaseApp.Messaging(context.Background())
	if err != nil {
		panic("Error initializing Firebase Messaging client: " + err.Error())
	}
}

func SendNotification(c *gin.Context) {
	var req models.NotificationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: req.Title,
			Body:  req.Body,
		},
		Token: req.Token,
	}

	response, err := messagingClient.Send(context.Background(), message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification sent", "response": response})
}
