package models

type UpdateGroupChatData struct {
	Name        string   `json:"name"`
	Activity    string   `json:"activity"`
	CatchPhrase string   `json:"catchPhrase"`
	NewMembers  []string `json:"new_members"`
}
