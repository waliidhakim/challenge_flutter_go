package models

type UserStats struct {
	UserCount    int64 `json:"user_count"`
	MessageCount int64 `json:"message_count"`
}
