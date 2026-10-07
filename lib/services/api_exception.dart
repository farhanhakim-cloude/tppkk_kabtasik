// lib/services/api_exception.dart
// Exception bersama untuk service Dasawisma berbasis HTTP.

/// Error umum API (offline, timeout, 401, 403, 404, 500).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Error validasi 422 — membawa pesan per field agar form bisa menampilkannya.
class ApiValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  ApiValidationException(this.message, [Map<String, List<String>>? errors])
      : errors = errors ?? {};

  /// Pesan pertama untuk satu field server (mis. 'nama_anggota').
  String? firstErrorFor(String field) {
    final list = errors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  String toString() => message;
}
