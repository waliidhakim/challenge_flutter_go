package main

import (
	"backend/initializers"
	"backend/models"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func main() {
	// Obtenez le répertoire de travail actuel
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("Error getting current working directory: %v", err)
	}
	fmt.Println("Current working directory:", wd)

	// Chargez le fichier .env
	err = godotenv.Load(".env")
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_PORT"),
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_DB"),
	)

	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Unable to connect to the database")
	}

	ClearTables(DB)
	Load(DB)
	fmt.Println("Fixtures loaded successfully")
}

func ClearTables(db *gorm.DB) {
	db.Exec("DELETE FROM group_chat_messages")
	db.Exec("DELETE FROM group_chat_users")
	db.Exec("DELETE FROM group_chats")
	db.Exec("DELETE FROM users")
}

func Load(db *gorm.DB) {
	createUsers(db)
	createGroupChats(db)
	createGroupChatActivityParticipations(db)
}

func createUsers(db *gorm.DB) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte("123"), 10)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error hashing password")
		return
	}

	users := []models.User{
		{Phone: "000", Password: string(hashedPassword), Role: "admin", Firstname: "Admin", Lastname: "Admin", Username: "AdminUsername", Onboarding: false, AvatarUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/plankton.jpg"},
		{Phone: "111", Password: string(hashedPassword), Role: "user", Firstname: "OwnerGp1", Lastname: "OwnerGp1", Username: "OwenGp1Username", Onboarding: false, AvatarUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/bob.jpg"},
		{Phone: "222", Password: string(hashedPassword), Role: "user", Firstname: "member1Gp1", Lastname: "member1Gp1", Username: "member1Gp1Username", Onboarding: false, AvatarUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/carlo-tentacule.jpg"},
		{Phone: "333", Password: string(hashedPassword), Role: "user", Firstname: "member2Gp1", Lastname: "member2Gp1", Username: "member2Gp1Username", Onboarding: false, AvatarUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/captain+krab.jpg"},
		{Phone: "444", Password: string(hashedPassword), Role: "user", Firstname: "NoGroupe", Lastname: "NoGroupe", Username: "NoGroupeUsername", Onboarding: false, AvatarUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/Patrick-l-etoile-de-mer.jpg"},
	}

	for _, user := range users {
		if err := db.Create(&user).Error; err != nil {
			log.Fatalf("could not create user: %v", err)
		}
	}
}

func createGroupChats(db *gorm.DB) {
	var groupOwner models.User
	db.Where("phone = ?", "111").First(&groupOwner)

	var user1 models.User
	db.Where("phone = ?", "222").First(&user1)

	var user2 models.User
	db.Where("phone = ?", "333").First(&user2)

	groupChats := []models.GroupChat{
		{Name: "Group 1 Test", ImageUrl: "https://challange-esgi.s3.eu-central-1.amazonaws.com/biere.png", CatchPhrase: "Petite bière ce soir", Activity: "Sortie",
			Users: []models.GroupChatUser{
				{UserID: groupOwner.ID, Role: "owner"},
				{UserID: user1.ID, Role: "member"},
				{UserID: user2.ID, Role: "member"},
			},
		},
	}

	for _, groupChat := range groupChats {
		if err := db.Create(&groupChat).Error; err != nil {
			log.Fatalf("could not create group chat: %v", err)
		}
	}
}

func createGroupChatActivityParticipations(db *gorm.DB) {
	var groupOwner models.User
	db.Where("phone = ?", "111").First(&groupOwner)

	var user1 models.User
	db.Where("phone = ?", "222").First(&user1)

	var group1 models.GroupChat
	db.Where("name= ?", "Group 1 Test").First(&group1)

	now := time.Now()
	todayAt18h := time.Date(
		now.Year(), now.Month(), now.Day(),
		18, 0, 0, 0, now.Location(),
	)

	groupChatActivityParticipations := []models.GroupChatActivityParticipation{

		{
			UserID:            groupOwner.ID,
			GroupChatID:       int(group1.ID),
			ParticipationDate: todayAt18h,
		},

		{
			UserID:            user1.ID,
			GroupChatID:       int(group1.ID),
			ParticipationDate: todayAt18h,
		},
	}

	for _, groupChatActivityParticipation := range groupChatActivityParticipations {
		if err := db.Create(&groupChatActivityParticipation).Error; err != nil {
			log.Fatalf("could not create group chat activity participation: %v", err)
		}
	}

}
