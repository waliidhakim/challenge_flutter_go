class Location {
  final int ?id;
  final int ?groupID;
  final String ?name;
  final String ?address;

  Location({
    this.id,
    this.groupID,
    this.name,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['ID'],
      groupID: json['GroupChatID'],
      name: json['Name'],
      address: json['Address'],
    );
  }
}
