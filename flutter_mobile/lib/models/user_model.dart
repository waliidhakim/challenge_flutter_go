class User {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String avatarUrl;
  final String role;
  final String phone;
  final bool onboarding;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.avatarUrl,
    required this.role,
    required this.phone,
    required this.onboarding,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("User JSON: $json");
    return User(
      id: json['ID'],
      firstname: json['Firstname'] ?? '', // Gérer les valeurs null
      lastname: json['Lastname'] ?? '', // Gérer les valeurs null
      username: json['Username'] ?? '', // Gérer les valeurs null
      avatarUrl: json['AvatarUrl'] ?? '', // Gérer les valeurs null
      role: json['Role'] ?? '', // Gérer les valeurs null
      phone: json['Phone'] ?? '', // Gérer les valeurs null
      onboarding: json['Onboarding'] ?? false, // Gérer les valeurs null
    );
  }
}
