import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pemanfaatan_tanah.dart';
import '../../services/pemanfaatan_tanah_service.dart';

class PemanfaatanTanahFormScreen extends StatefulWidget {
  final PemanfaatanTanah? data;
  const PemanfaatanTanahFormScreen({super.key, this.data});
  @override
  State<PemanfaatanTanahFormScreen> createState() => _PemanfaatanTanahFormScreenState();
}

class _PemanfaatanTanahFormScreenState extends State<PemanfaatanTanahFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PemanfaatanTanahService();
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryLight = Color(0xFFECFDF5);
  late final TextEditingController _dasaWismaCtrl, _rtCtrl, _rwCtrl, _dusunCtrl, _desaCtrl, _kecCtrl, _catatanCtrl;
  String _tahun = '2026';
  final _tahunList = ['2024','2025','2026','2027'];
  final List<_ItemState> _items = [];
  bool _saving = false;
  bool get _isEdit => widget.data != null;
  static const _kategoriList = ['Peternakan','Perikanan','Warung Hidup','TOGA','Tanaman Keras Lainnya'];

  @override
  void initState(){
    super.initState();
    final d=widget.data;
    _dasaWismaCtrl=TextEditingController(text:d?.dasaWisma??'');
    _rtCtrl=TextEditingController(text:d?.rt??'');
    _rwCtrl=TextEditingController(text:d?.rw??'');
    _dusunCtrl=TextEditingController(text:d?.dusun??'');
    _desaCtrl=TextEditingController(text:d?.desa??'');
    _kecCtrl=TextEditingController(text:d?.kecamatan??'');
    _catatanCtrl=TextEditingController(text:d?.catatan??'');
    _tahun=d?.tahun??'2026';
    if(d!=null && d.items.isNotEmpty){ for(final it in d.items){ _items.add(_ItemState(kategori:it.kategori, komoditi:it.komoditi, jumlah:it.jumlah)); } } else { _items.add(_ItemState()); }
  }
  @override
  void dispose(){ _dasaWismaCtrl.dispose(); _rtCtrl.dispose(); _rwCtrl.dispose(); _dusunCtrl.dispose(); _desaCtrl.dispose(); _kecCtrl.dispose(); _catatanCtrl.dispose(); for(final it in _items) it.dispose(); super.dispose(); }

  void _tambah(){ HapticFeedback.selectionClick(); setState(()=>_items.add(_ItemState())); }
  void _hapus(int i){ if(_items.length<=1) return; HapticFeedback.selectionClick(); setState((){_items[i].dispose(); _items.removeAt(i);}); }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;
    final valid=_items.where((it)=> it.kategori!=null && it.komoditiCtrl.text.trim().isNotEmpty).toList();
    if(valid.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi minimal 1 komoditi (kategori & komoditi wajib)', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.orange[700], behavior: SnackBarBehavior.floating, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); return; }
    setState(()=>_saving=true);
    try{
      final list=valid.map((it)=> PemanfaatanItem(kategori: it.kategori!, komoditi: it.komoditiCtrl.text.trim(), jumlah: it.jumlahCtrl.text.trim())).toList();
      final payload=PemanfaatanTanah(id: widget.data?.id ?? '0', dasaWisma: _dasaWismaCtrl.text.trim(), rt: _rtCtrl.text.trim(), rw: _rwCtrl.text.trim(), dusun: _dusunCtrl.text.trim(), desa: _desaCtrl.text.trim(), kecamatan: _kecCtrl.text.trim(), tahun: _tahun, items: list, catatan: _catatanCtrl.text.trim());
      if(_isEdit) await _service.update(payload); else await _service.add(payload);
      if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit?'Data diperbarui':'Data berhasil disimpan', style: GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w600)), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context,true);
    }catch(e){ if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red[700], behavior: SnackBarBehavior.floating)); }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFFF8FAFC), appBar: AppBar(backgroundColor: Colors.white, elevation:0, scrolledUnderElevation:0, iconTheme: const IconThemeData(color:Color(0xFF0F172A)), title: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(_isEdit?'Edit Pemanfaatan Tanah':'Tambah Pemanfaatan Tanah', style:GoogleFonts.plusJakartaSans(fontSize:16,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text('AKU HATINYA PKK', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B)))]), actions:[if(_saving) const Padding(padding:EdgeInsets.only(right:16), child: Center(child: SizedBox(width:20,height:20, child:CircularProgressIndicator(strokeWidth:2.5)))) else TextButton(onPressed:_save, child: Text('Simpan', style:GoogleFonts.plusJakartaSans(fontSize:14,fontWeight:FontWeight.w700,color:_primary)))]),
      body: Form(key:_formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,120), children:[
        _section(Icons.location_on_rounded,'Identitas Wilayah','Lokasi kelompok dasa wisma'), const SizedBox(height:14),
        _field(ctrl:_dasaWismaCtrl,label:'Dasa Wisma',hint:'Mawar 01',icon:Icons.holiday_village_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_rtCtrl,label:'RT',hint:'01',icon:Icons.location_on_outlined)), const SizedBox(width:12), Expanded(child: _field(ctrl:_rwCtrl,label:'RW',hint:'05',icon:Icons.location_on_outlined))]),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_dusunCtrl,label:'Dusun',hint:'Cikunir',icon:Icons.landscape_outlined)), const SizedBox(width:12), Expanded(child: _field(ctrl:_desaCtrl,label:'Desa',hint:'Singaparna',icon:Icons.home_work_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null))]),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_kecCtrl,label:'Kecamatan',hint:'Singaparna',icon:Icons.map_outlined)), const SizedBox(width:12), Expanded(child: _dropdown(label:'Tahun',value:_tahun,items:_tahunList,onChanged:(v)=> setState(()=>_tahun=v!),icon:Icons.calendar_today_outlined))]),
        const SizedBox(height:28), _section(Icons.grass_rounded,'Daftar Pemanfaatan Tanah','Kategori, komoditi & jumlah'), const SizedBox(height:14),
        ...List.generate(_items.length, (i)=> _buildItem(i)), const SizedBox(height:10),
        OutlinedButton.icon(onPressed:_tambah, icon: const Icon(Icons.add_circle_outline_rounded,size:18), label: Text('Tambah Komoditi', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w700,fontSize:13.5)), style: OutlinedButton.styleFrom(foregroundColor:_primary, side: BorderSide(color:_primary.withValues(alpha:0.4),width:1.5), padding: const EdgeInsets.symmetric(vertical:14), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height:24), _field(ctrl:_catatanCtrl,label:'Catatan (Opsional)',hint:'Keterangan tambahan...',icon:Icons.notes_rounded, maxLines:3),
        const SizedBox(height:32), SizedBox(width:double.infinity, child: ElevatedButton(onPressed: _saving?null:_save, style: ElevatedButton.styleFrom(backgroundColor:_primary, foregroundColor:Colors.white, padding: const EdgeInsets.symmetric(vertical:16), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation:2), child: _saving? const SizedBox(height:20,width:20, child:CircularProgressIndicator(strokeWidth:2.5,color:Colors.white)): Text(_isEdit?'Perbarui Data':'Simpan Data', style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w700))))
      ])),
    );
  }

  Widget _buildItem(int index){
    final item=_items[index];
    return Container(margin: const EdgeInsets.only(bottom:12), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:item.kategori!=null?_primary.withValues(alpha:0.3):const Color(0xFFE2E8F0),width:item.kategori!=null?1.5:1), boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:0.04),blurRadius:8,offset:const Offset(0,2))]), child: Column(children:[
      Container(padding: const EdgeInsets.symmetric(horizontal:14,vertical:10), decoration:BoxDecoration(color:item.kategori!=null?_primaryLight:const Color(0xFFF8FAFC),borderRadius: const BorderRadius.vertical(top: Radius.circular(16))), child: Row(children:[Container(padding: const EdgeInsets.all(6), decoration:BoxDecoration(color:item.kategori!=null?_primary.withValues(alpha:0.15):Colors.grey.withValues(alpha:0.12),shape:BoxShape.circle), child:Icon(Icons.grass_rounded,size:16,color:item.kategori!=null?_primary:Colors.grey[400])), const SizedBox(width:8), Expanded(child: Text('Komoditi ${index+1}', style:GoogleFonts.plusJakartaSans(fontSize:13.5,fontWeight:FontWeight.w800,color:item.kategori!=null?_primary:const Color(0xFF94A3B8)))), if(_items.length>1) GestureDetector(onTap:()=>_hapus(index), child: Container(padding: const EdgeInsets.all(4), decoration:BoxDecoration(color:Colors.red.withValues(alpha:0.08),shape:BoxShape.circle), child: Icon(Icons.close_rounded,size:14,color:Colors.red[400])))])),
      Padding(padding: const EdgeInsets.fromLTRB(14,14,14,16), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        _label('Kategori'), const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8, children: _kategoriList.map((k){ final sel=item.kategori==k; return GestureDetector(onTap:(){ HapticFeedback.selectionClick(); setState(()=> item.kategori= sel?null:k); }, child: AnimatedContainer(duration: const Duration(milliseconds:180), padding: const EdgeInsets.symmetric(horizontal:12,vertical:7), decoration:BoxDecoration(color:sel?_primary:const Color(0xFFF1F5F9),borderRadius:BorderRadius.circular(20),border:Border.all(color:sel?_primary:const Color(0xFFE2E8F0))), child: Row(mainAxisSize:MainAxisSize.min, children:[if(sel) const Padding(padding:EdgeInsets.only(right:4), child: Icon(Icons.check_circle_rounded,size:13,color:Colors.white)), Text(k, style:GoogleFonts.plusJakartaSans(fontSize:12.5,fontWeight: sel?FontWeight.w700:FontWeight.w500,color: sel?Colors.white:const Color(0xFF475569)))]))); }).toList()),
        if(item.kategori!=null)...[const SizedBox(height:14), _label('Komoditi'), const SizedBox(height:8), Container(decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextField(controller:item.komoditiCtrl, style:GoogleFonts.plusJakartaSans(fontSize:14), decoration: InputDecoration(hintText:'Contoh: Lele, Kangkung, Jahe...', hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:Colors.grey[400]), prefixIcon: const Icon(Icons.inventory_2_outlined,size:18,color:Color(0xFF059669)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:14)))) , const SizedBox(height:14), _label('Jumlah / Volume'), const SizedBox(height:8), Container(decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextField(controller:item.jumlahCtrl, style:GoogleFonts.plusJakartaSans(fontSize:14), decoration: InputDecoration(hintText:'Contoh: 20 kg, 15 pohon, 30 ekor...', hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:Colors.grey[400]), prefixIcon: const Icon(Icons.scale_outlined,size:18,color:Color(0xFF059669)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:14)))) ]
      ]))
    ]));
  }
  Widget _label(String t)=> Text(t, style:GoogleFonts.plusJakartaSans(fontSize:13,fontWeight:FontWeight.w700,color:const Color(0xFF374151)));
  Widget _section(IconData icon,String title,String sub){ return Row(children:[Container(padding: const EdgeInsets.all(9), decoration:BoxDecoration(color:_primaryLight,borderRadius:BorderRadius.circular(12)), child: Icon(icon,size:18,color:_primary)), const SizedBox(width:12), Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(title, style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text(sub, style:GoogleFonts.plusJakartaSans(fontSize:11.5,color:const Color(0xFF64748B)))])]); }
  Widget _field({required TextEditingController ctrl,required String label,required String hint,required IconData icon, String? Function(String?)? validator, int maxLines=1, TextInputType keyboardType=TextInputType.text})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextFormField(controller:ctrl, validator:validator, keyboardType:keyboardType, maxLines:maxLines, style:GoogleFonts.plusJakartaSans(fontSize:14), decoration:InputDecoration(labelText:label,hintText:hint,prefixIcon:Icon(icon,size:18,color:_primary), hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:Colors.grey[400]), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:14))));
  Widget _dropdown({required String label,required String value,required List<String> items,required ValueChanged<String?> onChanged,required IconData icon})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), padding: const EdgeInsets.symmetric(horizontal:14,vertical:2), child: DropdownButtonFormField<String>(value:value,isExpanded:true,icon:const Icon(Icons.keyboard_arrow_down_rounded,color:Color(0xFF64748B)), decoration:InputDecoration(labelText:label,prefixIcon:Icon(icon,size:18,color:_primary), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding:EdgeInsets.zero), items:items.map((i)=>DropdownMenuItem(value:i, child: Text(i, style:GoogleFonts.plusJakartaSans(fontSize:13.5)))).toList(), onChanged:onChanged));
}

class _ItemState{
  String? kategori; final TextEditingController komoditiCtrl; final TextEditingController jumlahCtrl;
  _ItemState({this.kategori,String komoditi='',String jumlah=''}): komoditiCtrl=TextEditingController(text:komoditi), jumlahCtrl=TextEditingController(text:jumlah);
  void dispose(){ komoditiCtrl.dispose(); jumlahCtrl.dispose(); }
}
