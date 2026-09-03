// lib/models/user.dart

class User {
  final int? id;
  final String name;
  final String username;
  final String email;
  final List<String> roles;

  User({
    this.id,
    String? name,
    String? nama,
    this.username = '',
    this.email = '',
    List<String>? roles,
    String? role,
    String? jabatan,
  })  : name = name ?? nama ?? 'User',
        roles = roles ?? (role != null ? [role] : (jabatan != null ? [jabatan] : const []));

  // Compatibility getters
  String get nama => name;
  String get role => roles.isNotEmpty ? roles.first : 'Kader';
  String get jabatan => role;

  factory User.fromJson(Map<String, dynamic> json) {
    // Tangani jika response dibungkus key 'data' atau 'user'
    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : ((json['user'] is Map<String, dynamic>)
            ? json['user'] as Map<String, dynamic>
            : json);

    List<String> parsedRoles = [];
    if (map['roles'] != null && map['roles'] is List) {
      parsedRoles = (map['roles'] as List).map((r) {
        if (r is Map && r['name'] != null) return r['name'].toString();
        return r.toString();
      }).toList();
    } else if (map['role'] != null) {
      parsedRoles = [map['role'].toString()];
    }

    return User(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      name: map['name'] ?? map['nama'] ?? 'User',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      roles: parsedRoles,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nama': name,
    'username': username,
    'email': email,
    'roles': roles,
  };
}