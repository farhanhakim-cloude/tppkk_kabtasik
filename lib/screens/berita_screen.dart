// lib/screens/berita_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/berita.dart';
import '../services/berita_service.dart';
import 'berita_form_screen.dart';

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen>
    with SingleTickerProviderStateMixin {
  final BeritaService _beritaService = BeritaService();
  final TextEditingController _searchController = TextEditingController();

  List<Berita> _allBerita = [];
  List<Berita> _filteredBerita = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _selectedKecamatan;
  String? _selectedStatus;
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _kecamatanList = [
    'Semua',
    'Bantarkalong',
    'Bojongasih',
    'Bojonggambir',
    'Ciawi',
    'Cibalong',
    'Cigalontang',
    'Cikalong',
    'Cikatomas',
    'Cineam',
    'Cipatujah',
    'Cisayong',
    'Culamega',
    'Gunungtanjung',
    'Jamanis',
    'Jatiwaras',
    'Kadipaten',
    'Karangjaya',
    'Karangnunggal',
    'Leuwisari',
    'Mangunreja',
    'Manonjaya',
    'Padakembang',
    'Pagerageung',
    'Pancatengah',
    'Parungponteng',
    'Puspahiang',
    'Rajapolah',
    'Salawu',
    'Salopa',
    'Sariwangi',
    'Singaparna',
    'Sodonghilir',
    'Sukahening',
    'Sukaraja',
    'Sukarame',
    'Sukaratu',
    'Sukaresik',
    'Tanjungjaya',
    'Taraju',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _loadBerita();
    _searchController.addListener(_filterBerita);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBerita() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final berita = await _beritaService.getBerita();
      setState(() {
        _allBerita = berita;
        _filteredBerita = berita;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterBerita() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredBerita = _allBerita.where((berita) {
        final matchJudul = berita.judul.toLowerCase().contains(query);
        final matchDeskripsi = (berita.deskripsi ?? berita.konten ?? '')
            .toLowerCase()
            .contains(query);
        final matchKecamatan = _selectedKecamatan == null ||
            _selectedKecamatan == 'Semua' ||
            (berita.kecamatan ?? '').toLowerCase() ==
                _selectedKecamatan!.toLowerCase();
        final matchStatus = _selectedStatus == null ||
            _selectedStatus == 'Semua' ||
            (berita.status ?? '') == _selectedStatus;
        return (matchJudul || matchDeskripsi) && matchKecamatan && matchStatus;
      }).toList();
    });
  }

  Future<void> _refresh() async {
    await _loadBerita();
  }

  Future<void> _openTulisBerita() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeritaFormScreen()),
    );
    if (result == true) {
      await _refresh();
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter Berita',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 Filter Kecamatan
            DropdownButtonFormField<String>(
              value: _selectedKecamatan,
              decoration: InputDecoration(
                labelText: 'Kecamatan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              items: _kecamatanList.map((kec) {
                return DropdownMenuItem(value: kec, child: Text(kec));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKecamatan = value;
                  _filterBerita();
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),

            // 🔥 Filter Status
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
                DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _filterBerita();
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),

            if (_selectedKecamatan != null || _selectedStatus != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedKecamatan = null;
                    _selectedStatus = null;
                    _filterBerita();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Reset Filter'),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _openTulisBerita,
        backgroundColor: primary,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
        label: Text(
          'Tulis Berita',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Berita PKK',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              HapticFeedback.selectionClick();
              _refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Tulis Berita',
            onPressed: _openTulisBerita,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filterBerita();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (_) => _filterBerita(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const _ShimmerList()
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: _filteredBerita.isEmpty
                      ? _buildEmptyWidget()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: _filteredBerita.length,
                          itemBuilder: (context, index) {
                            final berita = _filteredBerita[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _BeritaCard(
                                  berita: berita,
                                  onRefresh: _refresh,
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat berita',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Terjadi kesalahan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 48,
              color: primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Berita',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isSearching ? 'Tidak ada hasil untuk pencarian' : 'Berita terbaru akan muncul di sini',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
          if (_isSearching) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterBerita();
              },
              child: const Text('Hapus pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// BERITA CARD
// ================================================================
class _BeritaCard extends StatefulWidget {
  final Berita berita;
  final VoidCallback onRefresh;

  const _BeritaCard({required this.berita, required this.onRefresh});

  @override
  State<_BeritaCard> createState() => _BeritaCardState();
}

class _BeritaCardState extends State<_BeritaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final berita = widget.berita;

    String tanggal = berita.createdAt ?? berita.tanggal ?? 'Tanggal tidak tersedia';
    String deskripsi = berita.deskripsi ?? berita.konten ?? 'Klik untuk membaca selengkapnya';
    deskripsi = deskripsi.replaceAll(RegExp(r'<[^>]*>'), '');

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        _showDetailDialog(context, berita);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Gambar dengan overlay status
              if (berita.fotoUrl != null && berita.fotoUrl!.isNotEmpty)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(17)),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: _buildBeritaImage(berita.fotoUrl!, primary),
                      ),
                    ),
                    // 🔥 Status Badge
                    if (berita.status != null && berita.status != 'approved')
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(berita.status!).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(berita.status!),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              else
                // Gradient accent bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.4)],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary.withOpacity(0.8), primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Berita Resmi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (berita.kecamatan != null &&
                                      berita.kecamatan!.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        berita.kecamatan!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tanggal,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      berita.judul,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deskripsi.length > 150 ? '${deskripsi.substring(0, 150)}...' : deskripsi,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: Colors.grey[600],
                        height: 1.55,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'Baca selengkapnya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // 🔥 GET STATUS COLOR
  // ================================================================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================================================================
  // 🔥 GET STATUS LABEL
  // ================================================================
  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return '⏳ Menunggu';
      case 'approved':
        return '✅ Disetujui';
      case 'rejected':
        return '❌ Ditolak';
      default:
        return status;
    }
  }

  // ================================================================
  // 🔥 SHOW DETAIL DIALOG
  // ================================================================
  void _showDetailDialog(BuildContext context, Berita berita) {
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Status badge di detail
                      if (berita.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(berita.status!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(berita.status!),
                            style: GoogleFonts.plusJakartaSans(
                              color: _getStatusColor(berita.status!),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        berita.judul,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            berita.createdAt ?? berita.tanggal ?? 'Tanggal tidak tersedia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (berita.kecamatan != null && berita.kecamatan!.isNotEmpty)
                            Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  berita.kecamatan!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (berita.fotoUrl != null && berita.fotoUrl!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: _buildBeritaImage(berita.fotoUrl!, primary),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, primary.withOpacity(0.4)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        berita.deskripsi ?? berita.konten ?? 'Tidak ada konten',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          color: Colors.grey[700],
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// 🔥 BUILD BERITA IMAGE
// ================================================================
Widget _buildBeritaImage(String pathOrUrl, Color primary) {
  if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
    return Image.network(
      pathOrUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: primary.withOpacity(0.08),
          child: Center(
            child: CircularProgressIndicator(
              color: primary,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildFallbackImage(primary),
    );
  }
  try {
    final file = File(pathOrUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(primary),
      );
    }
  } catch (_) {}
  return _buildFallbackImage(primary);
}

Widget _buildFallbackImage(Color primary) {
  return Container(
    color: primary.withOpacity(0.08),
    child: Center(
      child: Icon(Icons.newspaper_rounded, color: primary.withOpacity(0.6), size: 36),
    ),
  );
}

// ================================================================
// 🔥 SHIMMER LIST
// ================================================================
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF1F5F9),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}