package controllers

import (
	roles "backend/constants"
	"backend/initializers"
	"backend/models"
	roleCheck "backend/utils"
	utils "backend/utils"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// UserGet godoc
// @Summary Get users
// @Description Retrieves a list of users with pagination
// @Tags user
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param page query int false "Page number of the users list" default(1)
// @Param limit query int false "Number of users per page" default(3)
// @Success 200 {array} swaggermodels.UserResponseSwagger "List of users"
// @Failure 401 {string} string "Unauthorized if the user is not admin"
// @Router /user [get]
func UserGet(context *gin.Context) {
	if !roleCheck.IsAdmin(context) {
		context.Status(http.StatusUnauthorized)
		return
	}
	var users []models.User

	// Récupérer les paramètres de pagination de la requête
	page, _ := strconv.Atoi(context.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(context.DefaultQuery("limit", "3"))
	offset := (page - 1) * limit

	// Récupérer les utilisateurs avec pagination
	initializers.DB.Limit(limit).Offset(offset).Find(&users)

	// Renvoyer les utilisateurs avec le statut HTTP 200
	context.JSON(http.StatusOK, users)
}

// UserGetById godoc
// @Summary Get user by ID
// @Description Retrieves a user by their ID
// @Tags user
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "User ID"
// @Success 200 {object} swaggermodels.UserResponseSwagger "User found and returned"
// @Failure 401 {string} string "Unauthorized if not admin or not the account owner"
// @Failure 404 {string} string "User not found"
// @Failure 500 {string} string "Internal server error"
// @Router /user/{id} [get]
func UserGetById(context *gin.Context) {
	id := context.Param("id")

	if !roleCheck.IsAdminOrAccountOwner(context, id) {
		context.Status(http.StatusUnauthorized)
		return
	}
	var user models.User
	result := initializers.DB.First(&user, id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			context.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}
	context.JSON(http.StatusOK, user)
}

// UserPost godoc
// @Summary Add new user
// @Description Add a new user to the system
// @Tags user
// @Accept json
// @Produce json
// @Param user body swaggermodels.UserRequestSwagger true "Create user request"
// @Success 201 {object} swaggermodels.UserResponseSwagger "User successfully created"
// @Router /user [post]
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
		initializers.Logger.Errorln("POST User : Error hashing password")
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

// UserUpdate godoc
// @Summary Update user
// @Description Updates user information and optionally uploads a new avatar image
// @Tags user
// @Accept multipart/form-data
// @Produce json
// @Security ApiKeyAuth
// @Param id path string true "User ID"
// @Param firstname formData string false "First name of the user"
// @Param lastname formData string false "Last name of the user"
// @Param username formData string false "Username for the user"
// @Param password formData string false "Password for the user"
// @Param phone formData string false "Phone number of the user"
// @Param onboarding formData boolean false "Onboarding status"
// @Param avatar formData file false "Avatar image file"
// @Success 200 {object} swaggermodels.UserResponseSwagger "Successfully updated user"
// @Failure 400 {string} string "Bad request data"
// @Failure 401 {string} string "Unauthorized if not admin or account owner"
// @Failure 500 {string} string "Internal server error"
// @Router /user/{id} [patch]
func UserUpdate(context *gin.Context) {
	id := context.Param("id")
	if !roleCheck.IsAdminOrAccountOwner(context, id) {
		context.Status(http.StatusUnauthorized)
		return
	}
	var body struct {
		Firstname  string
		Lastname   string
		Username   string
		Password   string
		Phone      string
		Onboarding bool
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("UPDATE User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	fmt.Printf("--------------------update user with lastname: %s and username %s and onboarding: %t ---------------------------\n", body.Lastname, body.Username, body.Onboarding)

	// Réception du fichier
	file, err := context.FormFile("avatar")
	var avatarUrl string
	if err == nil {
		avatarUrl, err = utils.UploadImageToS3(*file, "user-avatars")
		if err != nil {
			context.Status(http.StatusInternalServerError)
			return
		}
	}

	fmt.Printf("--------------------avatarURL: %s ---------------------------\n", avatarUrl)

	var user models.User
	initializers.DB.First(&user, id)
	initializers.DB.Model(&user).Updates(map[string]interface{}{
		"Firstname":  body.Firstname,
		"Lastname":   body.Lastname,
		"Username":   body.Username,
		"Onboarding": body.Onboarding,
		"AvatarUrl":  avatarUrl,
	})
	context.JSON(http.StatusOK, user)
}

// UserDelete godoc
// @Summary Delete user
// @Description Delete a user from the system by user ID
// @Tags user
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Security ApiKeyAuth
// @Success 200 {string} string "User successfully deleted"
// @Failure 400 {string} string "Bad request if the ID is not provided or invalid"
// @Failure 401 {string} string "Unauthorized if the user is not admin or not the account owner"
// @Failure 500 {string} string "Internal server error"
// @Router /user/{id} [delete]
func UserDelete(context *gin.Context) {
	id := context.Param("id")
	if !roleCheck.IsAdminOrAccountOwner(context, id) {
		context.Status(http.StatusUnauthorized)
		return
	}
	initializers.DB.Delete(&models.User{}, id)
	context.Status(http.StatusOK)
}

// UserLogin godoc
// @Summary User login
// @Description Logs in a user using their phone number and password
// @Tags authentication
// @Accept json
// @Produce json
// @Param body body swaggermodels.UserLoginRequestSwagger true "Login credentials"
// @Success 200 {object} swaggermodels.UserLoginResponseSwagger "Successfully logged in"
// @Failure 400 {string} string "Wrong phone or password"
// @Failure 500 {string} string "Internal server error"
// @Router /user/login [post]
func UserLogin(context *gin.Context) {

	initializers.Logger.Info("UserLogin called")

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
		initializers.Logger.Errorln("Error logging user : Unknwon phone number")
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
		"token":      tokenString,
		"onboarding": user.Onboarding, // Ajouter cette ligne pour inclure le statut d'onboarding
		"userId":     user.ID,         // Ajouter cette ligne pour inclure l'ID utilisateur
		"username":   user.Username,
	})
}

// UserPostWithImage godoc
// @Summary Add new user with image
// @Description Registers a new user with additional avatar image
// @Tags user
// @Accept multipart/form-data
// @Produce json
// @Param firstname formData string true "First name of the user"
// @Param lastname formData string true "Last name of the user"
// @Param username formData string true "Username for the new user"
// @Param password formData string true "Password for the new user"
// @Param phone formData string true "Phone number of the user"
// @Param avatar formData file false "Avatar image file"
// @Success 201 {object} swaggermodels.UserRegistrationWithImageResponseSwagger "User successfully created with image"
// @Failure 400 {object} map[string]string "Bad request data"
// @Failure 500 {object} map[string]string "Internal server error or failed to upload image"
// @Router /user/with-image [post]
func UserPostWithImage(context *gin.Context) {
	// Réception des données de formulaire
	firstname := context.PostForm("firstname")
	lastname := context.PostForm("lastname")
	username := context.PostForm("username")
	password := context.PostForm("password")
	phone := context.PostForm("phone")

	file, err := context.FormFile("avatar")
	var avatarUrl string
	if err == nil {
		avatarUrl, err = utils.UploadImageToS3(*file, "user-avatars")
		if err != nil {
			context.Status(http.StatusInternalServerError)
			return
		}
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
		AvatarUrl: avatarUrl, // URL de l'image stockée sur S3
		Role:      "user",    // Supposer que le rôle est défini quelque part comme constante
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

// UserRegister godoc
// @Summary Register new user
// @Description Registers a new user in the system using their phone number and password
// @Tags user
// @Accept json
// @Produce json
// @Param body body swaggermodels.UserRegisterRequestSwagger true "Registration data"
// @Success 201 {object} swaggermodels.UserRegisterResponseSwagger "Successfully registered and user created"
// @Failure 409 {object} map[string]string "User already exists, please login"
// @Failure 500 {object} map[string]string "Internal server error or failed to create user settings"
// @Router /register [post]
func UserRegister(context *gin.Context) {
	var body struct {
		Password string
		Phone    string
	}

	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln("POST User : Error binding body data to struct")
		context.Status(http.StatusInternalServerError)
		return
	}

	fmt.Printf("--------------------register user with number :  %s ---------------------------\n", body.Phone)
	var existingUser models.User
	if err := initializers.DB.Where("phone = ?", body.Phone).First(&existingUser).Error; err == nil {
		log.Println("User already exists, please login", err)
		context.JSON(http.StatusConflict, gin.H{"error": "User already exists, please login"})
		return
	}

	// Hachage du mot de passe
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
	if err != nil {
		log.Println("Error hashing password:", err)
		context.Status(http.StatusInternalServerError)
		return
	}

	user := models.User{
		Phone:      body.Phone,
		Password:   string(hashedPassword),
		Onboarding: true,
		Role:       "user",
	}

	if err := initializers.DB.Create(&user).Error; err != nil {
		log.Println("Database error:", err)
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}
	// Create Settings for the user
	setting := models.Setting{
		UserID:          int(user.ID),
		NotifyLevel:     models.All,
		NotifyThreshold: 5,
	}
	if err := initializers.DB.Create(&setting).Error; err != nil {
		log.Println("Database error:", err)
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user settings"})
		return
	}
	context.JSON(http.StatusCreated, gin.H{"user": user})
}

func UserGetGroupChatActivityParticipations(context *gin.Context) {
	id := context.Param("id")

	var user models.User
	if err := initializers.DB.First(&user, id).Error; err != nil {
		context.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	participations, err := user.GetGroupChatActivityParticipations(initializers.DB)
	if err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get participations"})
		return
	}

	context.JSON(http.StatusOK, participations)
}

func AdminLogin(context *gin.Context) {
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

	if user.Role != "admin" {
		context.JSON(http.StatusUnauthorized, gin.H{
			"error": "You don't have permission to access this page",
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
		"token":      tokenString,
		"onboarding": user.Onboarding, // Ajouter cette ligne pour inclure le statut d'onboarding
		"userId":     user.ID,         // Ajouter cette ligne pour inclure l'ID utilisateur
		"username":   user.Username,
		"role":       user.Role,
	})
}

func GetUserStats(c *gin.Context) {
	if !roleCheck.IsAdmin(c) {
		c.Status(http.StatusUnauthorized)
		return
	}

	var userCount int64
	var messageCount int64

	initializers.DB.Model(&models.User{}).Count(&userCount)
	initializers.DB.Model(&models.GroupChatMessage{}).Count(&messageCount)

	stats := &models.UserStats{
		UserCount:    userCount,
		MessageCount: messageCount,
	}

	c.JSON(http.StatusOK, stats)
}
