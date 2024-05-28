class User {
  final int id;
  final String firstName, lastName, username, password, avatarUrl, role, phone;
  final DateTime createdAt, updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.avatarUrl,
    required this.role,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      firstName: json['Firstname'],
      lastName: json['Lastname'],
      username: json['Username'],
      password: json['Password'],
      avatarUrl: json['AvatarUrl'],
      role: json['Role'],
      phone: json['Phone'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }
}
