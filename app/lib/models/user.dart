class User {
  final int id;
  final String username;
  final String createdDate;

  User({required this.id, required this.username, required this.createdDate});

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      createdDate: json['createdDate'] ?? '',
    );
  }

  // Convert User to JSON (useful for storage)
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'createdDate': createdDate};
  }
}
