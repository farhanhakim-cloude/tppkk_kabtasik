import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Tasikmalaya default coordinates
  late double _lat;
  late double _lng;
  double _zoom = 15.0;

  // Offset in pixels for dragging simulation
  Offset _mapOffset = Offset.zero;
  Offset _dragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat ?? -7.3274;
    _lng = widget.initialLng ?? 108.2207;
  }

  void _updateCoordinatesFromOffset() {
    // Tasikmalaya base offset math
    setState(() {
      _lat = -7.3274 - (_mapOffset.dy / 10000) * (20 / _zoom);
      _lng = 108.2207 + (_mapOffset.dx / 10000) * (20 / _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi Rumah',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed_rounded),
            onPressed: () {
              setState(() {
                _mapOffset = Offset.zero;
                _lat = -7.3274;
                _lng = 108.2207;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Simulated Map Canvas (Gesture detector for panning)
          GestureDetector(
            onPanStart: (details) {
              _dragStart = details.localPosition - _mapOffset;
            },
            onPanUpdate: (details) {
              setState(() {
                _mapOffset = details.localPosition - _dragStart;
              });
              _updateCoordinatesFromOffset();
            },
            child: ClipRect(
              child: CustomPaint(
                size: Size.infinite,
                painter: _MapPainter(
                  offset: _mapOffset,
                  zoom: _zoom,
                  primaryColor: primary,
                ),
              ),
            ),
          ),

          // 2. Fixed Center Pin Marker
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing indicator for accuracy
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withOpacity(0.2),
                        border: Border.all(color: primary, width: 2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: primary,
                    ),
                    const SizedBox(height: 40), // Offset to align pin tip
                  ],
                ),
              ),
            ),
          ),

          // 3. Search overlay & Info controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari wilayah/RT/RW di Tasikmalaya...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Zoom buttons
          Positioned(
            right: 16,
            bottom: 180,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      if (_zoom < 20) _zoom += 1.0;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onPressed: () {
                    setState(() {
                      if (_zoom > 10) _zoom -= 1.0;
                    });
                  },
                ),
              ],
            ),
          ),

          // 5. Selected Coordinate Info panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.my_location_rounded, color: primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Koordinat Terpilih',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tasikmalaya, Jawa Barat, Indonesia',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Latitude: ${_lat.toStringAsFixed(6)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700])),
                        Text('Longitude: ${_lng.toStringAsFixed(6)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {'lat': _lat, 'lng': _lng});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        'Gunakan Lokasi Ini',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.grey[700], size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

// Custom Painter to draw a premium stylized simulated map vector
class _MapPainter extends CustomPainter {
  final Offset offset;
  final double zoom;
  final Color primaryColor;

  _MapPainter({required this.offset, required this.zoom, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()..color = const Color(0xFFF1F5F9); // map background land
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    final double scale = zoom / 15.0;

    // Save state for translation
    canvas.save();
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);

    // Draw some mock land features: Parks (green areas)
    final paintPark = Paint()..color = const Color(0xFFDCFCE7)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-500, -300, 300, 200), const Radius.circular(30)), paintPark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(150, -400, 400, 250), const Radius.circular(50)), paintPark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-300, 180, 500, 300), const Radius.circular(40)), paintPark);

    // Draw a River (blue curve)
    final paintRiver = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    final riverPath = Path()
      ..moveTo(-800, -600)
      ..quadraticBezierTo(-300, -200, 200, -500)
      ..quadraticBezierTo(700, -800, 900, 300);
    canvas.drawPath(riverPath, paintRiver);

    // Draw some mock blocks/neighborhoods (buildings)
    final paintBuilding = Paint()..color = const Color(0xFFE2E8F0);
    for (int x = -600; x < 600; x += 120) {
      for (int y = -600; y < 600; y += 120) {
        // Exclude river or park zones dynamically
        if ((x > -400 && x < -100 && y > -300 && y < -100) || (x > 150 && x < 550 && y > -400 && y < -150)) continue;
        if (x.abs() % 240 == 0 && y.abs() % 240 == 0) {
          canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 35, 35), paintBuilding);
          canvas.drawRect(Rect.fromLTWH(x + 50.0, y.toDouble(), 30, 25), paintBuilding);
          canvas.drawRect(Rect.fromLTWH(x.toDouble(), y + 45.0, 45, 30), paintBuilding);
        }
      }
    }

    // Draw Roads (grid style and major highways)
    final paintRoadMain = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintRoadLine = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Major Highways (thick white lines)
    paintRoadMain.strokeWidth = 16;
    canvas.drawLine(const Offset(-1000, 0), const Offset(1000, 0), paintRoadMain);
    canvas.drawLine(const Offset(0, -1000), const Offset(0, 1000), paintRoadMain);
    canvas.drawLine(const Offset(-800, -800), const Offset(800, 800), paintRoadMain);

    // Minor Roads (thinner white lines)
    paintRoadMain.strokeWidth = 8;
    for (double i = -1000; i <= 1000; i += 200) {
      if (i != 0) {
        canvas.drawLine(Offset(-1000, i), Offset(1000, i), paintRoadMain);
        canvas.drawLine(Offset(i, -1000), Offset(i, 1000), paintRoadMain);
      }
    }

    // Major highway dashed center line
    paintRoadLine.strokeWidth = 1.2;
    paintRoadLine.color = const Color(0xFFF59E0B); // Yellow highway divider
    canvas.drawLine(const Offset(-1000, 0), const Offset(1000, 0), paintRoadLine);
    canvas.drawLine(const Offset(0, -1000), const Offset(0, 1000), paintRoadLine);

    // Draw some points of interest (mock markers on land)
    final paintPoi = Paint()..color = primaryColor.withOpacity(0.6);
    canvas.drawCircle(const Offset(-200, 80), 8, paintPoi);
    canvas.drawCircle(const Offset(220, 200), 8, paintPoi);
    canvas.drawCircle(const Offset(-400, -250), 10, paintPoi);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
