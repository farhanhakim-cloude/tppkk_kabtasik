// lib/models/notifikasi.dart
// Notifikasi lonceng HP: agenda baru dari admin kabupaten.
// Sumber: GET /api/notifikasi (auth Sanctum).

class Notifikasi {
  final String id;
  final String type;
  final String message;
  final String? judul;
  final int? agendaId;
  final String? tanggal;
  final String? lokasi;
  final bool isRead;
  final String createdAt;

  const Notifikasi({
    required this.id,
    required this.type,
    required this.message,
    this.judul,
    this.agendaId,
    this.tanggal,
    this.lokasi,
    required this.isRead,
    required this.createdAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Notifikasi(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'info').toString(),
      message: (json['message'] ?? 'Ada pembaruan.').toString(),
      judul: json['judul']?.toString(),
      agendaId: asInt(json['agenda_id']),
      tanggal: json['tanggal']?.toString(),
      lokasi: json['lokasi']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  Notifikasi dibaca() => Notifikasi(
        id: id,
        type: type,
        message: message,
        judul: judul,
        agendaId: agendaId,
        tanggal: tanggal,
        lokasi: lokasi,
        isRead: true,
        createdAt: createdAt,
      );
}
