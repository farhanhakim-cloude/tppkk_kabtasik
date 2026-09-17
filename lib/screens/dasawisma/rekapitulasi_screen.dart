import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/rekapitulasi_service.dart';

class RekapitulasiScreen extends StatefulWidget {
  final String? initialDesa;
  final String? initialKecamatan;
  const RekapitulasiScreen({super.key, this.initialDesa, this.initialKecamatan});
  @override
  State<RekapitulasiScreen> createState() => _RekapitulasiScreenState();
}

class _RekapitulasiScreenState extends State<RekapitulasiScreen> with SingleTickerProviderStateMixin {
  final _service = RekapitulasiService();
  late TabController _tabController;
  // filters
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _dusunCtrl = TextEditingController();
  final _desaCtrl = TextEditingController();
  final _kecCtrl = TextEditingController();
  String _tahun = '2026';
  final _tahunList = ['','2024','2025','2026','2027'];

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length:2, vsync:this);
    _desaCtrl.text = widget.initialDesa ?? '';
    _kecCtrl.text = widget.initialKecamatan ?? '';
  }
  @override
  void dispose(){ _tabController.dispose(); _rtCtrl.dispose(); _rwCtrl.dispose(); _dusunCtrl.dispose(); _desaCtrl.dispose(); _kecCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.white, elevation:0, scrolledUnderElevation:0, iconTheme: const IconThemeData(color:Color(0xFF0F172A)), title: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Rekapitulasi Dasawisma', style:GoogleFonts.plusJakartaSans(fontSize:16,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text('Auto roll-up Opsi A tanpa ACC', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B))) ]), bottom: TabBar(controller:_tabController, labelStyle:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w700,fontSize:13), unselectedLabelStyle:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w500,fontSize:13), labelColor: const Color(0xFF0F766E), unselectedLabelColor: const Color(0xFF64748B), indicatorColor: const Color(0xFF0D9488), tabs: const [Tab(text:'Sheet 7 - Data & Kegiatan'), Tab(text:'Sheet 8 - Ibu & Bayi')])),
      body: Column(children:[
        // Filter bar
        Container(color:Colors.white, padding: const EdgeInsets.fromLTRB(12,10,12,10), child: Column(children:[
          Row(children:[Expanded(child: _miniField(_rtCtrl,'RT',Icons.location_on_outlined)), const SizedBox(width:8), Expanded(child: _miniField(_rwCtrl,'RW',Icons.location_on_outlined)), const SizedBox(width:8), Expanded(child: _miniField(_dusunCtrl,'Dusun',Icons.landscape_outlined)), const SizedBox(width:8), Expanded(child: _miniField(_desaCtrl,'Desa',Icons.home_work_outlined))]),
          const SizedBox(height:8),
          Row(children:[Expanded(child: _miniField(_kecCtrl,'Kecamatan',Icons.map_outlined)), const SizedBox(width:8), Expanded(child: Container(decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(10),border:Border.all(color:const Color(0xFFE2E8F0))), padding: const EdgeInsets.symmetric(horizontal:10), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value:_tahun, isExpanded:true, hint: Text('Tahun', style:GoogleFonts.plusJakartaSans(fontSize:12)), items:_tahunList.map((e)=> DropdownMenuItem(value:e, child: Text(e.isEmpty?'Semua Tahun':e, style:GoogleFonts.plusJakartaSans(fontSize:12)))).toList(), onChanged:(v){ setState(()=>_tahun=v??''); })))), const SizedBox(width:8), ElevatedButton.icon(onPressed:()=> setState((){}), icon: const Icon(Icons.search_rounded,size:16), label: Text('Terapkan', style:GoogleFonts.plusJakartaSans(fontSize:12,fontWeight:FontWeight.w700)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor:Colors.white, padding: const EdgeInsets.symmetric(horizontal:16,vertical:10), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))))]),
        ])),
        const Divider(height:1),
        Expanded(child: TabBarView(controller:_tabController, children:[ _buildSheet7(), _buildSheet8()])),
      ]),
    );
  }

  Widget _miniField(TextEditingController ctrl, String label, IconData icon)=> Container(decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(10),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextField(controller:ctrl, style:GoogleFonts.plusJakartaSans(fontSize:12), decoration: InputDecoration(labelText:label, labelStyle:GoogleFonts.plusJakartaSans(fontSize:10,color:const Color(0xFF64748B)), prefixIcon: Icon(icon,size:14,color:const Color(0xFF0D9488)), border:InputBorder.none, enabledBorder:InputBorder.none, focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:8,vertical:8), isDense:true)));

  Widget _buildSheet7(){
    return FutureBuilder<List<RekapRow>>(
      future: _service.getRekapSheet7(rt: _rtCtrl.text.trim(), rw: _rwCtrl.text.trim(), dusun: _dusunCtrl.text.trim(), desa: _desaCtrl.text.trim(), kecamatan: _kecCtrl.text.trim(), tahun: _tahun),
      builder: (ctx, snap){
        if(!snap.hasData) return const Center(child: CircularProgressIndicator(color:Color(0xFF0D9488)));
        final rows = snap.data!;
        return FutureBuilder<RekapTotal>(future: _service.getTotalSheet7(rt:_rtCtrl.text.trim(),rw:_rwCtrl.text.trim(),dusun:_dusunCtrl.text.trim(),desa:_desaCtrl.text.trim(),kecamatan:_kecCtrl.text.trim(),tahun:_tahun), builder:(ctx2,totalSnap){
          final total = totalSnap.data;
          return Column(children:[
            if(rows.isEmpty) Expanded(child: Center(child: Column(mainAxisAlignment:MainAxisAlignment.center, children:[Icon(Icons.table_chart_outlined,size:48,color:Colors.grey[300]), const SizedBox(height:8), Text('Belum ada data Dasawisma', style:GoogleFonts.plusJakartaSans(color:const Color(0xFF64748B))), Text('Data akan otomatis terisi saat kader Dasawisma input', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF94A3B8))) ])))
            else Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF0F766E)),
              headingTextStyle: GoogleFonts.plusJakartaSans(fontSize:10,color:Colors.white,fontWeight:FontWeight.w700),
              dataTextStyle: GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF0F172A)),
              columnSpacing:12, horizontalMargin:12, headingRowHeight:48, dataRowMinHeight:36,
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Nama KRT')),
                DataColumn(label: Text('Dasa\nWisma'), numeric:true),
                DataColumn(label: Text('RT/RW')),
                DataColumn(label: Text('Desa')),
                DataColumn(label: Text('KK')),
                DataColumn(label: Text('L')),
                DataColumn(label: Text('P')),
                DataColumn(label: Text('Balita')),
                DataColumn(label: Text('PUS')),
                DataColumn(label: Text('WUS')),
                DataColumn(label: Text('Hamil')),
                DataColumn(label: Text('Menyusui')),
                DataColumn(label: Text('Lansia')),
                DataColumn(label: Text('3Buta')),
                DataColumn(label: Text('Khusus')),
                DataColumn(label: Text('Tidak\n Layak')),
                DataColumn(label: Text('Jamban')),
                DataColumn(label: Text('Sampah')),
                DataColumn(label: Text('SPAL')),
                DataColumn(label: Text('PDAM')),
                DataColumn(label: Text('Sumur')),
                DataColumn(label: Text('Lain')),
                DataColumn(label: Text('Beras')),
                DataColumn(label: Text('NonBeras')),
                DataColumn(label: Text('UP2K')),
                DataColumn(label: Text('Tanah')),
                DataColumn(label: Text('Industri')),
                DataColumn(label: Text('Kesling')),
              ],
              rows: [
                ...List.generate(rows.length, (i){ final r=rows[i]; return DataRow(cells: [DataCell(Text('${i+1}')), DataCell(Text(r.namaKepalaRumahTangga)), DataCell(Text(r.dasaWisma)), DataCell(Text('${r.rt}/${r.rw}')), DataCell(Text(r.desa)), DataCell(Text('${r.jumlahKk}')), DataCell(Text('${r.l}')), DataCell(Text('${r.p}')), DataCell(Text('${r.balitaL + r.balitaP}')), DataCell(Text('${r.pus}')), DataCell(Text('${r.wus}')), DataCell(Text('${r.ibuHamil}')), DataCell(Text('${r.ibuMenyusui}')), DataCell(Text('${r.lansia}')), DataCell(Text('${r.tigaButaL + r.tigaButaP}')), DataCell(Text('${r.berkebutuhanKhusus}')), DataCell(Text('${r.kriteriaTidakLayak}')), DataCell(Text('${r.punyaJamban}')), DataCell(Text('${r.punyaTempatSampah}')), DataCell(Text('${r.punyaSpal}')), DataCell(Text('${r.sumberAirPdam}')), DataCell(Text('${r.sumberAirSumur}')), DataCell(Text('${r.sumberAirLainnya}')), DataCell(Text('${r.makananBeras}')), DataCell(Text('${r.makananNonBeras}')), DataCell(Text('${r.up2k}')), DataCell(Text('${r.tanahPekarangan}')), DataCell(Text('${r.industriRumah}')), DataCell(Text('${r.kesehatanLingkungan}'))]); }),
                if(total!=null) DataRow(color: WidgetStateProperty.all(const Color(0xFFECFDF5)), cells: [const DataCell(Text('')), DataCell(Text('JUMLAH', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), const DataCell(Text('')), const DataCell(Text('')), const DataCell(Text('')), DataCell(Text('${total.jumlahKk}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.l}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.p}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.balitaL + total.balitaP}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.pus}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.wus}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.ibuHamil}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.ibuMenyusui}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.lansia}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.tigaButaL + total.tigaButaP}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.berkebutuhanKhusus}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.kriteriaTidakLayak}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.punyaJamban}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.punyaTempatSampah}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.punyaSpal}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.sumberAirPdam}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.sumberAirSumur}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.sumberAirLainnya}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.makananBeras}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.makananNonBeras}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.up2k}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.tanahPekarangan}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.industriRumah}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800))), DataCell(Text('${total.kesehatanLingkungan}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800)))]),
              ],
            )))),
            if(total!=null) Container(color: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal:16,vertical:8), child: Row(children:[Expanded(child: Text('Total ${rows.length} keluarga', style:GoogleFonts.plusJakartaSans(color:Colors.white,fontSize:12,fontWeight:FontWeight.w600))), Text('Otomatis dari Dasawisma', style:GoogleFonts.plusJakartaSans(color:Colors.white70,fontSize:11))]))
          ]);
        });
      },
    );
  }

  Widget _buildSheet8(){
    return FutureBuilder<IbuBayiRekap>(
      future: _service.getRekapSheet8(rt: _rtCtrl.text.trim(), rw: _rwCtrl.text.trim(), dusun: _dusunCtrl.text.trim(), desa: _desaCtrl.text.trim(), tahun: _tahun),
      builder:(ctx,snap){
        if(!snap.hasData) return const Center(child: CircularProgressIndicator(color:Color(0xFF0D9488)));
        final r=snap.data!;
        return ListView(padding: const EdgeInsets.all(16), children:[
          Container(padding: const EdgeInsets.all(16), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Rekapitulasi Ibu Hamil, Melahirkan, Nifas & Kelahiran Bayi', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800,fontSize:14,color:const Color(0xFF0F172A))), const SizedBox(height:4), Text('Filter wilayah otomatis - data dasar dari Dasawisma', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B))), const SizedBox(height:16), Wrap(spacing:12,runSpacing:12, children:[_stat('Ibu Hamil','${r.hamil}',const Color(0xFF8B5CF6),Icons.pregnant_woman_rounded),_stat('Melahirkan','${r.melahirkan}',const Color(0xFFEC4899),Icons.child_care_rounded),_stat('Nifas','${r.nifas}',const Color(0xFF06B6D4),Icons.healing_rounded),_stat('Bayi L','${r.bayiLahirL}',const Color(0xFF3B82F6),Icons.boy_rounded),_stat('Bayi P','${r.bayiLahirP}',const Color(0xFFF43F5E),Icons.girl_rounded),_stat('Akta Ada','${r.aktaAda}',const Color(0xFF10B981),Icons.verified_rounded),_stat('Akta Tdk','${r.aktaTidak}',const Color(0xFFF59E0B),Icons.pending_rounded),_stat('Ibu Meninggal','${r.ibuMeninggal}',Colors.red,Icons.warning_rounded),_stat('Bayi M L','${r.bayiMeninggalL}',const Color(0xFF6366F1),Icons.heart_broken_rounded),_stat('Bayi M P','${r.bayiMeninggalP}',const Color(0xFFEC4899),Icons.heart_broken_rounded),_stat('Balita M','${r.balitaMeninggal}',const Color(0xFFDC2626),Icons.sick_rounded)] ) ])),
          const SizedBox(height:12),
          Container(padding: const EdgeInsets.all(12), decoration:BoxDecoration(color:const Color(0xFFFEF3C7),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFFDE68A))), child: Row(children:[const Icon(Icons.info_outline_rounded,size:16,color:Color(0xFF92400E)), const SizedBox(width:8), Expanded(child: Text('Data ini terisi otomatis dari menu Rekap Ibu & Anak Dasawisma. Filter RT/RW/Dusun/Desa/Kecamatan/Tahun di atas akan memfilter kedua sheet sekaligus.', style:GoogleFonts.plusJakartaSans(fontSize:11.5,color:const Color(0xFF92400E))))])),
        ]);
      },
    );
  }

  Widget _stat(String label, String val, Color color, IconData icon)=> Container(width:110, padding: const EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:color.withValues(alpha:0.2)),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:0.04),blurRadius:6,offset:const Offset(0,2))]), child: Column(children:[Container(padding: const EdgeInsets.all(6), decoration:BoxDecoration(color:color.withValues(alpha:0.1),shape:BoxShape.circle), child: Icon(icon,size:18,color:color)), const SizedBox(height:6), Text(val, style:GoogleFonts.plusJakartaSans(fontSize:18,fontWeight:FontWeight.w900,color:color)), Text(label, textAlign:TextAlign.center, style:GoogleFonts.plusJakartaSans(fontSize:10,fontWeight:FontWeight.w600,color:const Color(0xFF64748B)))]));
}
