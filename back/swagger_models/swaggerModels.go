package swaggermodels

import "time"

type UserResponseSwagger struct {
	ID        uint   `json:"id"`
	Firstname string `json:"firstname"`
	Lastname  string `json:"lastname"`
	Username  string `json:"username"`
	Phone     string `json:"phone"`
	AvatarUrl string `json:"avatarUrl"`
	Role      string `json:"role"`
}

type UserRequestSwagger struct {
	Firstname string `json:"firstname"`
	Lastname  string `json:"lastname"`
	Username  string `json:"username"`
	Phone     string `json:"phone"`
	Password  string `json:"password"`
}

type UserLoginRequestSwagger struct {
	Phone    string `json:"phone" example:"1234567890"`
	Password string `json:"password" example:"s3cret"`
}

type UserLoginResponseSwagger struct {
	Token      string `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	Onboarding bool   `json:"onboarding" example:"false"`
	UserId     uint   `json:"userId" example:"1"`
	Username   string `json:"username" example:"johndoe"`
}

// UserRegisterRequest représente les données requises pour enregistrer un nouvel utilisateur.
type UserRegisterRequestSwagger struct {
	Phone    string `json:"phone" example:"1234567890"`
	Password string `json:"password" example:"s3cr3t"`
}

// UserRegisterResponse représente les données renvoyées après l'enregistrement réussi d'un utilisateur.
type UserRegisterResponseSwagger struct {
	ID         uint   `json:"id" example:"1"`
	Phone      string `json:"phone" example:"1234567890"`
	Onboarding bool   `json:"onboarding" example:"true"`
}

type UserRegistrationWithImageResponseSwagger struct {
	ID        uint   `json:"id" example:"1"`
	Firstname string `json:"firstname" example:"John"`
	Lastname  string `json:"lastname" example:"Doe"`
	Username  string `json:"username" example:"johndoe"`
	Phone     string `json:"phone" example:"1234567890"`
	AvatarUrl string `json:"avatarUrl" example:"https://example.com/default.png"`
	Role      string `json:"role" example:"user"`
}

// for get users
type UserSwagger struct {
	ID         uint       `json:"id" example:"1"`
	CreatedAt  time.Time  `json:"createdAt" example:"2024-07-18T16:30:18.337205Z"`
	UpdatedAt  time.Time  `json:"updatedAt" example:"2024-07-18T16:30:18.337205Z"`
	DeletedAt  *time.Time `json:"deletedAt" swaggertype:"string" example:"null"`
	Firstname  string     `json:"firstname" example:"Admin"`
	Lastname   string     `json:"lastname" example:"Admin"`
	Username   string     `json:"username" example:"AdminUsername"`
	AvatarUrl  string     `json:"avatarUrl" example:"https://example.com/avatar.jpg"`
	Role       string     `json:"role" example:"admin"`
	Phone      string     `json:"phone" example:"000"`
	Onboarding bool       `json:"onboarding" example:"false"`
}

type GroupChatSwagger struct {
	Name        string
	Activity    string
	CatchPhrase string
	Alert       string
	ImageUrl    string
	AlertDate   time.Time
}

type LogPaginationResponseSwagger struct {
	LogLevel     string
	LogMessage   string
	CreationDate time.Time
}

type FeatureFlippedSwagger struct {
	FeatureName string `json:"featureName" example:"New UI Feature"`
	IsActive    bool   `json:"isActive" example:true`
}
