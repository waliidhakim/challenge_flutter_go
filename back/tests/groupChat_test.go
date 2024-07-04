package test

import (
	"backend/models"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/mock"
)

// Mock de la base de données
type MockDB struct {
	mock.Mock
}

func (db *MockDB) GetGroupChatByID(id string) (*models.GroupChat, error) {
	args := db.Called(id)
	return args.Get(0).(*models.GroupChat), args.Error(1)
}

func TestGetGroupChatByID(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.Default()

	mockDB := new(MockDB)
	mockDB.On("GetGroupChatByID", "1").Return(&models.GroupChat{Name: "Test Group"}, nil)

	r.GET("/groupchat/:id", func(c *gin.Context) {
		id := c.Param("id")
		groupChat, err := mockDB.GetGroupChatByID(id)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, groupChat)
	})

	req, _ := http.NewRequest(http.MethodGet, "/groupchat/1", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status code %d, but got %d", http.StatusOK, w.Code)
	}
}
