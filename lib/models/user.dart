// lib/models/user.dart

class User {
  final int? id;
  final String name;
  final String username;
  final String email;
  final List<String> roles;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? json['nama'] ?? 'User',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'roles': roles,
  };
}