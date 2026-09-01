import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart'; // FIX: sesuaikan path ini dengan lokasi asli di project Anda

class GaleriAgendaScreen extends StatefulWidget {
  const GaleriAgendaScreen({super.key});

  @override
  State<GaleriAgendaScreen> createState() => _GaleriAgendaScreenState();
}

class _GaleriAgendaScreenState extends State<GaleriAgendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // FIX: state untuk data asli dari API (ganti dummy itemCount: 6 & 4)
  late Future<List<dynamic>> _galeriFuture;
  late Future<List<dynamic>> _agendaFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _galeriFuture = _apiService.getGaleri();
    _agendaFuture = _apiService.getAgenda();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  // FIX: helper ambil field dengan beberapa kemungkinan nama key,
  // supaya tidak crash kalau nama field di API sedikit beda dari dugaan.
  String _pickString(Map item, List<String> keys, {String fallback = '-'}) {
    for (final k in keys) {
      if (item[k] != null && item[k].toString().trim().isNotEmpty) {
        return item[k].toString();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Galeri & Agenda',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.black87),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Galeri Kegiatan'),
                Tab(text: 'Agenda PKK'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Galeri — FIX: FutureBuilder ganti GridView.builder dummy
          FutureBuilder<List<dynamic>>(
            future: _galeriFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Gagal memuat galeri.\n${snapshot.error}',
                  onRetry: () => setState(() => _galeriFuture = _apiService.getGaleri()),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const _EmptyState(message: 'Belum ada foto galeri.');
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  // FIX: sesuaikan nama key kalau ternyata beda dari dugaan
                  final judul = _pickString(item, ['judul', 'nama', 'title']);
                  final fotoUrl = _pickString(item, ['foto_url', 'gambar', 'image_url'], fallback: '');
                  final tanggal = _pickString(item, ['created_at_formatted', 'tanggal', 'created_at']);

                  return _FadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: fotoUrl.isNotEmpty
                                  ? Image.network(
                                      fotoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: primary.withOpacity(0.05),
                                        child: Icon(Icons.image_not_supported_outlined, size: 40, color: primary.withOpacity(0.3)),
                                      ),
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: primary.withOpacity(0.05),
                                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: primary.withOpacity(0.05),
                                      child: Icon(Icons.image_outlined, size: 40, color: primary.withOpacity(0.3)),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judul,
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1E293B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tanggal,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Tab Agenda — FIX: FutureBuilder ganti ListView.separated dummy
          FutureBuilder<List<dynamic>>(
            future: _agendaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Gagal memuat agenda.\n${snapshot.error}',
                  onRetry: () => setState(() => _agendaFuture = _apiService.getAgenda()),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const _EmptyState(message: 'Belum ada agenda.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  // FIX: sesuaikan nama key kalau ternyata beda dari dugaan
                  final judul = _pickString(item, ['judul', 'nama_kegiatan', 'title']);
                  final lokasi = _pickString(item, ['lokasi', 'tempat'], fallback: '-');
                  final waktu = _pickString(item, ['waktu', 'jam'], fallback: '-');
                  final tanggalRaw = _pickString(item, ['tanggal', 'tanggal_mulai'], fallback: '');

                  // FIX: parsing tanggal jadi tanggal & bulan untuk kotak di kiri
                  String tgl = '-';
                  String bulan = '';
                  try {
                    final date = DateTime.parse(tanggalRaw);
                    tgl = date.day.toString();
                    const namaBulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
                    bulan = namaBulan[date.month];
                  } catch (_) {
                    // biarkan default '-' kalau format tanggal tidak sesuai
                  }

                  return _FadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(tgl, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20, color: primary)),
                                const SizedBox(height: 2),
                                Text(bulan, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12, color: primary)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judul,
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(lokasi, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600])),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(waktu, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// FIX: widget kecil untuk state error dengan tombol coba lagi
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

// FIX: widget kecil untuk state kosong
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 13)),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: SlideTransition(position: _slide, child: widget.child));
  }
}