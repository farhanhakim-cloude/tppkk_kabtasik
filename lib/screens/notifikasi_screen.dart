// lib/screens/notifikasi_screen.dart
// Layar lonceng bersama kader & dasawisma: agenda baru dari kabupaten.
// Gaya dinas (biru 0072BC, paper F4F6F9, radius 12, PlusJakartaSans).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notifikasi.dart';
import '../services/notifikasi_service.dart';
import '../widgets/skeleton.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  static const _biru = Color(0xFF0072BC);
  static const _ink = Color(0xFF1A2B3C);
  static const _muted = Color(0xFF5B6B7C);
  static const _line = Color(0xFFE1E7EE);
  static const _paper = Color(0xFFF4F6F9);

  final _service = NotifikasiService();
  List<Notifikasi> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final items = await _service.getNotifikasi();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _bacaSemua() async {
    try {
      await _service.bacaSemua();
      if (!mounted) return;
      setState(() => _items = _items.map((e) => e.dibaca()).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai dibaca')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _buka(Notifikasi n) async {
    HapticFeedback.selectionClick();
    if (!n.isRead) {
      try {
        await _service.tandaiBaca(n.id);
      } catch (_) {}
      if (!mounted) return;
      setState(() => _items = _items.map((e) => e.id == n.id ? e.dibaca() : e).toList());
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _biru.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_rounded, color: _biru, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    n.judul ?? 'Agenda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              n.message,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted, height: 1.5),
            ),
            if ((n.tanggal ?? '').isNotEmpty || (n.lokasi ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              if ((n.tanggal ?? '').isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Text(n.tanggal!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink)),
                  ],
                ),
              if ((n.lokasi ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(n.lokasi!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink)),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((e) => !e.isRead).length;
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _biru,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifikasi',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _bacaSemua,
              child: Text('Tandai dibaca',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _biru,
        child: _loading
            ? const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                physics: NeverScrollableScrollPhysics(),
                child: SkeletonList(count: 5),
              )
            : _error.isNotEmpty && _items.isEmpty
                ? _buildError()
                : _items.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildItem(_items[i]),
                      ),
      ),
    );
  }

  Widget _buildItem(Notifikasi n) {
    return InkWell(
      onTap: () => _buka(n),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: n.isRead ? _line : _biru.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _biru.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_rounded, color: _biru, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.judul ?? 'Pemberitahuan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _ringkasWaktu(n.createdAt),
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ringkasWaktu(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      children: [
        const Icon(Icons.notifications_none_rounded, size: 56, color: _line),
        const SizedBox(height: 12),
        Text('Belum ada notifikasi',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 4),
        Text('Agenda baru dari kabupaten akan muncul di sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted)),
      ],
    );
  }

  Widget _buildError() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      children: [
        const Icon(Icons.cloud_off_rounded, size: 56, color: _line),
        const SizedBox(height: 12),
        Text(_error,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted)),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: _biru,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}
