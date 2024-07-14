package models

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Firstname  string
	Lastname   string
	Username   string
	Password   string `gorm:"not null;default:null"`
	AvatarUrl  string
	Role       string
	Phone      string `gorm:"unique; not null;default:null"`
	Onboarding bool
}

// Method to get GroupChatActivityParticipations with GroupChat name
func (u *User) GetGroupChatActivityParticipations(db *gorm.DB) ([]map[string]interface{}, error) {
	var participations []map[string]interface{}
	rows, err := db.Table("group_chat_activity_participations").
		Select("group_chat_activity_participations.*, group_chats.name as group_chat_name").
		Joins("left join group_chats on group_chats.id = group_chat_activity_participations.group_chat_id").
		Where("group_chat_activity_participations.user_id = ?", u.ID).
		Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var participation map[string]interface{}
		if err := db.ScanRows(rows, &participation); err != nil {
			return nil, err
		}
		participations = append(participations, participation)
	}

	return participations, nil
}
