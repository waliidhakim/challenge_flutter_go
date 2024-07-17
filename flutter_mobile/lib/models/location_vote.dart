class LocationVote {
  final int ?id;
  final int ?locationId;
  final DateTime ?voteDate;
  final int ?userId;
  final int ?groupId;

  LocationVote({
    this.id,
    this.locationId,
    this.voteDate,
    this.userId,
    this.groupId,
  });

  factory LocationVote.fromJson(Map<String, dynamic> json) {
    return LocationVote(
      id: json['ID'],
      locationId: json['LocationId'],
      voteDate: DateTime.parse(json['VoteDate']),
      userId: json['UserId'],
      groupId: json['GroupId'],
    );
  }
}
