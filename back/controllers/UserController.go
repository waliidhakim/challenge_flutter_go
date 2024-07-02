package controllers

import (
	roles "backend/constants"
	"backend/initializers"
	"backend/models"
	roleCheck "backend/utils"
	"errors"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func UserGet(context *gin.Context) {
	var users []models.User
	initializers.DB.Find(&users)
	context.JSON(http.StatusOK, users)
}

func UserGetById(context *gin.Context) {
	id := context.Param("id")
	var user models.User
	initializers.DB.First(&user, id)
	context.JSON(http.StatusOK, user)
}

func UserPost(context *gin.Context) {
	var body struct {
		Firstname string
		Lastname  string
		Username  string
		Password  string
		Phone     string
	}

	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	user := models.User{
		Firstname: body.Firstname,
		Lastname:  body.Lastname,
		Username:  body.Username,
		Phone:     body.Phone,
		Password:  string(hashedPassword),
		AvatarUrl: "/default.png",
		Role:      roles.User,
	}
	result := initializers.DB.Create(&user)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			initializers.Logger.Infoln(result.Error)
			context.JSON(http.StatusBadRequest, gin.H{
				"error": "Phone should be unique",
			})
			return
		} else {
			initializers.Logger.Errorln(result.Error)
			context.Status(http.StatusInternalServerError)
			return
		}
	}
	context.JSON(http.StatusCreated, user)
}

func UserUpdate(context *gin.Context) {
	id := context.Param("id")
	if !roleCheck.IsAdminOrAccountOwner(context, id) {
		context.Status(http.StatusUnauthorized)
		return
	}
	var body struct {
		Firstname string
		Lastname  string
		Username  string
		Password  string
		Phone     string
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("UPDATE User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}
	var user models.User
	initializers.DB.First(&user, id)
	initializers.DB.Model(&user).Updates(models.User{
		Firstname: body.Firstname,
		Lastname:  body.Lastname,
		Username:  body.Username,
		Password:  body.Password,
		Phone:     body.Phone,
	})
	context.JSON(http.StatusOK, user)
}

func UserDelete(context *gin.Context) {
	id := context.Param("id")
	if !roleCheck.IsAdminOrAccountOwner(context, id) {
		context.Status(http.StatusUnauthorized)
		return
	}
	initializers.DB.Delete(&models.User{}, id)
	context.Status(http.StatusOK)
}

func UserLogin(context *gin.Context) {
	var body struct {
		Phone    string
		Password string
	}
	bindErr := context.Bind(&body)
	if bindErr != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}
	var user models.User
	initializers.DB.First(&user, "phone = ?", body.Phone)

	if user.ID == 0 {
		// Phone is unknown in that case but to avoid information disclosure we send a vague message
		context.JSON(http.StatusBadRequest, gin.H{
			"error": "Wrong phone or password",
		})
		return
	}

	bcryptErr := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
	if bcryptErr != nil {
		// User is found but password is wrong, to avoid information disclosure we send a vague message
		context.JSON(http.StatusBadRequest, gin.H{
			"error": "Wrong phone or password",
		})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,
		"exp": time.Now().Add(time.Hour * 6).Unix(),
	})

	tokenString, jwtErr := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if jwtErr != nil {
		initializers.Logger.Errorln("JWT Error when signing token", jwtErr)
		context.JSON(http.StatusInternalServerError, gin.H{
			"error": "Internal server error",
		})
		return
	}

	context.SetSameSite(http.SameSiteLaxMode)
	// @todo change "secure" to true when on production
	context.SetCookie("Authorization", tokenString, 3600*6, "", "", false, true)
	context.JSON(http.StatusOK, gin.H{
		"token": tokenString,
	})
}

func UserPostWithImage(context *gin.Context) {
	// Réception des données de formulaire
	firstname := context.PostForm("firstname")
	lastname := context.PostForm("lastname")
	username := context.PostForm("username")
	password := context.PostForm("password")
	phone := context.PostForm("phone")

	// Réception du fichier
	file, err := context.FormFile("avatar")
	if err != nil {
		initializers.Logger.Errorln("Error retrieving the file")
		context.JSON(http.StatusBadRequest, gin.H{"error": "No file is received"})
		return
	}

	// Créer une session AWS
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("eu-central-1"), // ou votre région AWS
	})
	if err != nil {
		log.Println("Error creating AWS session:", err)
		context.Status(http.StatusInternalServerError)
		return
	}

	// Créer un uploader avec la session
	uploader := s3manager.NewUploader(sess)

	// Ouvrir le fichier
	src, err := file.Open()
	if err != nil {
		log.Println("Error opening file:", err)
		context.Status(http.StatusInternalServerError)
		return
	}
	defer src.Close()

	// Uploader le fichier
	uploadOutput, err := uploader.Upload(&s3manager.UploadInput{
		Bucket: aws.String("challange-esgi"),
		Key:    aws.String("user-avatars/" + file.Filename),
		Body:   src,
	})
	if err != nil {
		log.Println("Failed to upload file to S3:", err)
		context.Status(http.StatusInternalServerError)
		return
	}

	// Hasher le mot de passe
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Println("Error hashing password:", err)
		context.Status(http.StatusInternalServerError)
		return
	}

	// Créer l'utilisateur avec l'URL de l'image sur S3
	user := models.User{
		Firstname: firstname,
		Lastname:  lastname,
		Username:  username,
		Phone:     phone,
		Password:  string(hashedPassword),
		AvatarUrl: uploadOutput.Location, // URL de l'image stockée sur S3
		Role:      "user",                // Supposer que le rôle est défini quelque part comme constante
	}

	// Sauvegarder l'utilisateur dans la base de données
	if err := initializers.DB.Create(&user).Error; err != nil {
		log.Println("Database error:", err)
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Répondre avec succès et les données de l'utilisateur
	context.JSON(http.StatusCreated, gin.H{"user": user})
}
