// lib/models/user.dart

class User {
  final int? id;
  final String name;
  final String username;
  final String email;
  final List<String> roles;
  final String? mobileRole;
  final String kecamatan;
  final String desa;

  User({
    this.id,
    String? name,
    String? nama,
    this.username = '',
    this.email = '',
    List<String>? roles,
    String? role,
    String? jabatan,
    String? mobileRole,
    String? kecamatan,
    String? desa,
    String? kelurahan,
  })  : name = name ?? nama ?? 'User',
        mobileRole = mobileRole ?? role,
        kecamatan = kecamatan ?? '',
        desa = desa ?? kelurahan ?? '',
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
      mobileRole: map['role']?.toString(),
      kecamatan: (map['kecamatan'] ?? '').toString(),
      desa: (map['desa'] ?? map['kelurahan'] ?? map['nama_desa'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nama': name,
    'username': username,
    'email': email,
    'roles': roles,
    'role': mobileRole ?? role,
    'kecamatan': kecamatan,
    'desa': desa,
  };

  bool get hasWilayah => kecamatan.isNotEmpty && desa.isNotEmpty;
  String get wilayahLabel =>
      hasWilayah ? '$desa, Kec. $kecamatan' : 'Wilayah belum diatur';
}
