package models

type NotificationRequest struct {
	Token string `json:"token"`
	Title string `json:"title"`
	Body  string `json:"body"`
}
