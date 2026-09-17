import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/kegiatan_warga.dart';
import '../../services/kegiatan_warga_service.dart';

class KegiatanWargaFormScreen extends StatefulWidget {
  final KegiatanWarga? data;
  const KegiatanWargaFormScreen({super.key, this.data});
  @override
  State<KegiatanWargaFormScreen> createState() => _KegiatanWargaFormScreenState();
}

class _KegiatanWargaFormScreenState extends State<KegiatanWargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KegiatanWargaService();
  static const Color _primary = Color(0xFF0EA5E9);
  static const Color _primaryLight = Color(0xFFF0F9FF);
  late final TextEditingController _dasaWismaCtrl, _rtCtrl, _rwCtrl, _dusunCtrl, _desaCtrl, _kecCtrl;
  String _tahun = '2026';
  final _tahunList = ['2024','2025','2026','2027'];
  late List<KegiatanItem> _items;
  bool _saving=false;
  bool get _isEdit => widget.data!=null;

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
    _tahun=d?.tahun??'2026';
    if(d!=null){ _items=d.items.map((e)=> KegiatanItem(nama:e.nama, aktif:e.aktif, keterangan:e.keterangan)).toList(); } else { _items=KegiatanWarga.defaultKegiatan(); }
  }
  @override
  void dispose(){ _dasaWismaCtrl.dispose(); _rtCtrl.dispose(); _rwCtrl.dispose(); _dusunCtrl.dispose(); _desaCtrl.dispose(); _kecCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;
    setState(()=>_saving=true);
    try{
      final payload=KegiatanWarga(id: widget.data?.id ?? '0', dasaWisma: _dasaWismaCtrl.text.trim(), rt: _rtCtrl.text.trim(), rw: _rwCtrl.text.trim(), dusun: _dusunCtrl.text.trim(), desa: _desaCtrl.text.trim(), kecamatan: _kecCtrl.text.trim(), tahun: _tahun, items: _items);
      if(_isEdit) await _service.update(payload); else await _service.add(payload);
      if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit?'Data diperbarui':'Data disimpan', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w600)), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context,true);
    }catch(e){ if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e', style:GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red[700])); }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFFF8FAFC), appBar: AppBar(backgroundColor:Colors.white,elevation:0,scrolledUnderElevation:0,iconTheme: const IconThemeData(color:Color(0xFF0F172A)), title: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(_isEdit?'Edit Kegiatan Warga':'Tambah Kegiatan Warga', style:GoogleFonts.plusJakartaSans(fontSize:16,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text('7 kegiatan Y/T + keterangan', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B)))]), actions:[if(_saving) const Padding(padding:EdgeInsets.only(right:16), child: Center(child: SizedBox(width:20,height:20, child: CircularProgressIndicator(strokeWidth:2.5)))) else TextButton(onPressed:_save, child: Text('Simpan', style:GoogleFonts.plusJakartaSans(fontSize:14,fontWeight:FontWeight.w700,color:_primary)))]),
      body: Form(key:_formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,120), children:[
        _section(Icons.location_on_rounded,'Identitas Wilayah','Lokasi kelompok'), const SizedBox(height:14),
        _field(ctrl:_dasaWismaCtrl,label:'Dasa Wisma',hint:'Mawar 01',icon:Icons.holiday_village_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_rtCtrl,label:'RT',hint:'01',icon:Icons.location_on_outlined)), const SizedBox(width:12), Expanded(child: _field(ctrl:_rwCtrl,label:'RW',hint:'05',icon:Icons.location_on_outlined))]),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_dusunCtrl,label:'Dusun',hint:'Cikunir',icon:Icons.landscape_outlined)), const SizedBox(width:12), Expanded(child: _field(ctrl:_desaCtrl,label:'Desa',hint:'Singaparna',icon:Icons.home_work_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null))]),
        const SizedBox(height:10), Row(children:[Expanded(child: _field(ctrl:_kecCtrl,label:'Kecamatan',hint:'Singaparna',icon:Icons.map_outlined)), const SizedBox(width:12), Expanded(child: _dropdown(label:'Tahun',value:_tahun,items:_tahunList,onChanged:(v)=> setState(()=>_tahun=v!),icon:Icons.calendar_today_outlined))]),
        const SizedBox(height:28), _section(Icons.diversity_3_rounded,'7 Kegiatan Warga','Toggle Y/T & isi keterangan'), const SizedBox(height:14),
        ...List.generate(_items.length, (i)=> _buildKegiatanCard(i)),
        const SizedBox(height:32), SizedBox(width:double.infinity, child: ElevatedButton(onPressed:_saving?null:_save, style: ElevatedButton.styleFrom(backgroundColor:_primary,foregroundColor:Colors.white, padding: const EdgeInsets.symmetric(vertical:16), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation:2), child: _saving? const SizedBox(height:20,width:20, child: CircularProgressIndicator(strokeWidth:2.5,color:Colors.white)): Text(_isEdit?'Perbarui':'Simpan', style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w700))))
      ])),
    );
  }

  Widget _buildKegiatanCard(int index){
    final item=_items[index];
    return Container(margin: const EdgeInsets.only(bottom:10), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:item.aktif? const Color(0xFFBBF7D0):const Color(0xFFE2E8F0)),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:0.04),blurRadius:6,offset:const Offset(0,2))]), child: Column(children:[
      Padding(padding: const EdgeInsets.fromLTRB(14,12,14,10), child: Row(children:[Container(width:28,height:28, decoration:BoxDecoration(color:item.aktif?_primary:const Color(0xFFF1F5F9),shape:BoxShape.circle), child: Center(child: Text('${index+1}', style:GoogleFonts.plusJakartaSans(fontSize:12,fontWeight:FontWeight.w800,color:item.aktif?Colors.white:const Color(0xFF64748B))))), const SizedBox(width:10), Expanded(child: Text(item.nama, style:GoogleFonts.plusJakartaSans(fontSize:13.5,fontWeight:FontWeight.w700,color:const Color(0xFF0F172A)))), Transform.scale(scale:0.9, child: Switch(value:item.aktif, activeColor:Colors.white, activeTrackColor: _primary, inactiveThumbColor:Colors.white, inactiveTrackColor: const Color(0xFFE2E8F0), onChanged:(v){ HapticFeedback.selectionClick(); setState(()=> _items[index]=item.copyWith(aktif:v)); })) ])),
      if(item.aktif) Padding(padding: const EdgeInsets.fromLTRB(14,0,14,14), child: Container(decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextFormField(initialValue:item.keterangan, onChanged:(v)=> _items[index]=item.copyWith(keterangan:v), style:GoogleFonts.plusJakartaSans(fontSize:13.5), maxLines:2, decoration: InputDecoration(hintText:'Keterangan (jenis kegiatan yang diikuti)...', hintStyle:GoogleFonts.plusJakartaSans(fontSize:12.5,color:Colors.grey[400]), prefixIcon: const Icon(Icons.edit_note_rounded,size:18,color:Color(0xFF0EA5E9)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:12)))) ),
    ]));
  }

  Widget _section(IconData icon,String title,String sub){ return Row(children:[Container(padding: const EdgeInsets.all(9), decoration:BoxDecoration(color:_primaryLight,borderRadius:BorderRadius.circular(12)), child: Icon(icon,size:18,color:_primary)), const SizedBox(width:12), Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(title, style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text(sub, style:GoogleFonts.plusJakartaSans(fontSize:11.5,color:const Color(0xFF64748B)))])]); }
  Widget _field({required TextEditingController ctrl,required String label,required String hint,required IconData icon, String? Function(String?)? validator})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextFormField(controller:ctrl,validator:validator, style:GoogleFonts.plusJakartaSans(fontSize:14), decoration:InputDecoration(labelText:label,hintText:hint,prefixIcon:Icon(icon,size:18,color:_primary), hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:Colors.grey[400]), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:14))));
  Widget _dropdown({required String label,required String value,required List<String> items,required ValueChanged<String?> onChanged,required IconData icon})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), padding: const EdgeInsets.symmetric(horizontal:14,vertical:2), child: DropdownButtonFormField<String>(value:value,isExpanded:true,icon:const Icon(Icons.keyboard_arrow_down_rounded,color:Color(0xFF64748B)), decoration:InputDecoration(labelText:label,prefixIcon:Icon(icon,size:18,color:_primary), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding:EdgeInsets.zero), items:items.map((i)=>DropdownMenuItem(value:i, child: Text(i, style:GoogleFonts.plusJakartaSans(fontSize:13.5)))).toList(), onChanged:onChanged));
}
