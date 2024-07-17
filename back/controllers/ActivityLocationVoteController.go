package controllers

import (
	"backend/initializers"
	"backend/models"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"time"
)

func ActivityLocationVoteGet(context *gin.Context) {
	var activityLocations []models.GroupChatActivityLocationVote
	initializers.DB.Find(&activityLocations)
	context.JSON(http.StatusOK, activityLocations)
}

func ActivityLocationVoteGetByLocationIdToday(context *gin.Context) {
	locationId := context.Param("location_id")
	var activityLocationsVotes []models.GroupChatActivityLocationVote
	today := time.Now().Format("2006-01-02")
	initializers.DB.Where("location_id = ? AND DATE(vote_date) = ?", locationId, today).Find(&activityLocationsVotes)
	context.JSON(http.StatusOK, activityLocationsVotes)
}

func ActivityLocationVoteGetByGroupIdToday(context *gin.Context) {
	groupChatId := context.Param("group_chat_id")
	var locations []models.GroupChatActivityLocation
	initializers.DB.Where("group_chat_id = ?", groupChatId).Find(&locations)
	var activityLocationsVotes []models.GroupChatActivityLocationVote
	for _, location := range locations {
		var votes []models.GroupChatActivityLocationVote
		initializers.DB.Where("location_id = ?", location.ID).Find(&votes)
		for _, vote := range votes {
			if vote.VoteDate.Format("2006-01-02") == time.Now().Format("2006-01-02") {
				activityLocationsVotes = append(activityLocationsVotes, vote)
			}
		}
	}
	context.JSON(http.StatusOK, activityLocationsVotes)
}

func ActivityLocationVoteCreate(context *gin.Context) {
	var body struct {
		VoteDate   time.Time
		LocationId int
		GroupId    int
	}
	err := context.Bind(&body)
	if err != nil {
		initializers.Logger.Errorln(err)
		context.JSON(http.StatusBadRequest, gin.H{"error": "Error while binding request"})
	}

	fmt.Println("BODY LOCTION ID", body.LocationId)
	fmt.Println(body)

	userId, userErr := context.Get("userId")
	if userErr != true {
		initializers.Logger.Errorln("POST ActivityParticipation : Error getting user id from context")
		context.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	vote := &models.GroupChatActivityLocationVote{
		UserId:     userId.(uint),
		VoteDate:   body.VoteDate,
		LocationId: body.LocationId,
		GroupId:    body.GroupId,
	}
	initializers.DB.Create(&vote)
	context.JSON(http.StatusCreated, vote)
}

func ActivityLocationVoteDelete(context *gin.Context) {
	voteID := context.Param("id")
	var vote models.GroupChatActivityLocationVote
	initializers.DB.Where("id = ?", voteID).First(&vote)
	if vote.ID == 0 {
		context.JSON(http.StatusNotFound, gin.H{"error": "Vote not found"})
		return
	}
	initializers.DB.Delete(&vote)
	context.JSON(http.StatusOK, gin.H{"message": "Location deleted"})
}

func ActivityLocationVoteDeleteByGroupAndUser(context *gin.Context) {
	groupId := context.Param("group_id")
	userId := context.MustGet("userId").(uint)
	var activityLocationsVote []models.GroupChatActivityLocationVote
	initializers.DB.Where("group_id = ? AND user_id = ?", groupId, userId).Find(&activityLocationsVote)
	initializers.DB.Delete(&activityLocationsVote)
	context.JSON(http.StatusOK, gin.H{"message": "Votes deleted"})
}

func ActivityLocationVoteDeleteByUserAndLocationIdToday(context *gin.Context) {
	locationId := context.Param("location_id")
	userId := context.MustGet("userId").(uint)
	var activityLocationsVote models.GroupChatActivityLocationVote
	today := time.Now().Format("2006-01-02")
	initializers.DB.Where("location_id = ? AND user_id = ? AND DATE(vote_date) = ?", locationId, userId, today).First(&activityLocationsVote)
	initializers.DB.Delete(&activityLocationsVote)
	context.JSON(http.StatusOK, gin.H{"message": "Votes deleted"})
}
