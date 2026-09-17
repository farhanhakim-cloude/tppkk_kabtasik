import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dasawisma_catatan_keluarga.dart';
import '../../services/dasawisma_catatan_keluarga_service.dart';

class CatatanKeluargaFormScreen extends StatefulWidget {
  final DasawismaCatatanKeluarga? data;
  const CatatanKeluargaFormScreen({super.key, this.data});
  @override
  State<CatatanKeluargaFormScreen> createState() => _CatatanKeluargaFormScreenState();
}

class _CatatanKeluargaFormScreenState extends State<CatatanKeluargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DasawismaCatatanKeluargaService();
  static const Color _primary = Color(0xFFDC2626);
  static const Color _primaryLight = Color(0xFFFEF2F2);

  late final TextEditingController _dasaWismaCtrl, _rtCtrl, _rwCtrl, _dusunCtrl, _desaCtrl, _kecCtrl, _catatanDariCtrl, _ketUmumCtrl;
  String _tahun='2026', _kriteria='Sehat', _sumberAir='Sumur', _tempatSampah='Ada';
  final _tahunList=['2024','2025','2026','2027'];
  final List<_AnggotaState> _anggota=[];
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
    _catatanDariCtrl=TextEditingController(text:d?.catatanDari??'');
    _ketUmumCtrl=TextEditingController(text:d?.keteranganUmum??'');
    _tahun=d?.tahun??'2026';
    _kriteria=d?.kriteriaRumah??'Sehat';
    _sumberAir=d?.sumberAir??'Sumur';
    _tempatSampah=d?.tempatSampah??'Ada';
    if(d!=null && d.items.isNotEmpty){ for(final it in d.items){ _anggota.add(_AnggotaState.fromModel(it)); } } else { _anggota.add(_AnggotaState()); }
  }
  @override
  void dispose(){ _dasaWismaCtrl.dispose(); _rtCtrl.dispose(); _rwCtrl.dispose(); _dusunCtrl.dispose(); _desaCtrl.dispose(); _kecCtrl.dispose(); _catatanDariCtrl.dispose(); _ketUmumCtrl.dispose(); for(final a in _anggota) {
    a.dispose();
  } super.dispose(); }

  void _tambah(){ HapticFeedback.selectionClick(); setState(()=>_anggota.add(_AnggotaState())); }
  void _hapus(int i){ if(_anggota.length<=1) return; HapticFeedback.selectionClick(); setState((){_anggota[i].dispose(); _anggota.removeAt(i);}); }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;
    final valid=_anggota.where((a)=> a.namaCtrl.text.trim().isNotEmpty).toList();
    if(valid.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi minimal 1 anggota keluarga', style:GoogleFonts.plusJakartaSans()), backgroundColor:Colors.orange[700], behavior:SnackBarBehavior.floating)); return; }
    setState(()=>_saving=true);
    try{
      final items=valid.map((a)=> DasawismaCatatanKeluargaItem(
        namaAnggota: a.namaCtrl.text.trim(),
        statusPerkawinan: a.statusKawin,
        jenisKelamin: a.jk,
        tempatLahir: a.tempatCtrl.text.trim(),
        tanggalLahirUmur: a.ttlCtrl.text.trim(),
        agama: a.agama,
        pendidikan: a.pendidikan,
        pekerjaan: a.pekerjaanCtrl.text.trim(),
        berkebutuhanKhusus: a.khususCtrl.text.trim().isEmpty? 'Tidak': a.khususCtrl.text.trim(),
        penghayatanPancasila: a.pancasila, gotongRoyong: a.gotong, pendidikanKeterampilan: a.didik, pengembanganKoperasi: a.koperasi, pangan: a.pangan, sandang: a.sandang, kesehatan: a.kesehatan, perencanaanSehat: a.perencanaan, keterangan: a.ketCtrl.text.trim(),
      )).toList();
      final payload=DasawismaCatatanKeluarga(id: widget.data?.id ?? '0', tahun:_tahun, dasaWisma:_dasaWismaCtrl.text.trim(), rt:_rtCtrl.text.trim(), rw:_rwCtrl.text.trim(), dusun:_dusunCtrl.text.trim(), desa:_desaCtrl.text.trim(), kecamatan:_kecCtrl.text.trim(), catatanDari:_catatanDariCtrl.text.trim(), kriteriaRumah:_kriteria, sumberAir:_sumberAir, tempatSampah:_tempatSampah, items:items, keteranganUmum:_ketUmumCtrl.text.trim());
      if(_isEdit) {
        await _service.update(payload);
      } else {
        await _service.add(payload);
      }
      if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit?'Data diperbarui':'Data disimpan', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w600)), backgroundColor:const Color(0xFF10B981), behavior:SnackBarBehavior.floating)); Navigator.pop(context,true);
    }catch(e){ if(!mounted) return; setState(()=>_saving=false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor:Colors.red[700])); }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFFF8FAFC), appBar: AppBar(backgroundColor:Colors.white,elevation:0,scrolledUnderElevation:0,iconTheme: const IconThemeData(color:Color(0xFF0F172A)), title: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(_isEdit?'Edit Catatan Keluarga':'Tambah Catatan Keluarga', style:GoogleFonts.plusJakartaSans(fontSize:16,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text('19 kolom + 8 kegiatan PKK', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B)))]), actions:[if(_saving) const Padding(padding:EdgeInsets.only(right:16), child: Center(child: SizedBox(width:20,height:20, child:CircularProgressIndicator(strokeWidth:2.5)))) else TextButton(onPressed:_save, child: Text('Simpan', style:GoogleFonts.plusJakartaSans(fontSize:14,fontWeight:FontWeight.w700,color:_primary)))]),
      body: Form(key:_formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,120), children:[
        _section(Icons.location_on_rounded,'Identitas Wilayah','Header catatan keluarga'), const SizedBox(height:14),
        _field(ctrl:_catatanDariCtrl,label:'Catatan Keluarga Dari',hint:'Contoh: RT 01 - keluarga Bpk. Ahmad',icon:Icons.badge_outlined),
        const SizedBox(height:10), _field(ctrl:_dasaWismaCtrl,label:'Anggota Kelompok Dasa Wisma',hint:'Mawar 01',icon:Icons.holiday_village_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null),
        const SizedBox(height:10), Row(children:[Expanded(child:_field(ctrl:_rtCtrl,label:'RT',hint:'01',icon:Icons.location_on_outlined)), const SizedBox(width:12), Expanded(child:_field(ctrl:_rwCtrl,label:'RW',hint:'05',icon:Icons.location_on_outlined)), const SizedBox(width:12), Expanded(child:_dropdown(label:'Tahun',value:_tahun,items:_tahunList,onChanged:(v)=>setState(()=>_tahun=v!),icon:Icons.calendar_today_outlined))]),
        const SizedBox(height:10), Row(children:[Expanded(child:_field(ctrl:_dusunCtrl,label:'Dusun',hint:'Cikunir',icon:Icons.landscape_outlined)), const SizedBox(width:12), Expanded(child:_field(ctrl:_desaCtrl,label:'Desa',hint:'Singaparna',icon:Icons.home_work_outlined, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null))]),
        const SizedBox(height:10), Row(children:[Expanded(child:_field(ctrl:_kecCtrl,label:'Kecamatan',hint:'Singaparna',icon:Icons.map_outlined)), const SizedBox(width:12), Expanded(child:_dropdown(label:'Kriteria Rumah',value:_kriteria,items:['Sehat','Tidak Sehat'],onChanged:(v)=>setState(()=>_kriteria=v!),icon:Icons.home_outlined)),]),
        const SizedBox(height:10), Row(children:[Expanded(child:_dropdown(label:'Sumber Air',value:_sumberAir,items:['PDAM','Sumur','Sungai','DLL'],onChanged:(v)=>setState(()=>_sumberAir=v!),icon:Icons.water_drop_outlined)), const SizedBox(width:12), Expanded(child:_dropdown(label:'Tempat Sampah',value:_tempatSampah,items:['Ada','Tidak Ada'],onChanged:(v)=>setState(()=>_tempatSampah=v!),icon:Icons.delete_outline_rounded))]),
        const SizedBox(height:28), _section(Icons.family_restroom_rounded,'Daftar Anggota Keluarga','Isi 19 kolom per anggota'), const SizedBox(height:14),
        ...List.generate(_anggota.length, (i)=> _buildAnggota(i)),
        const SizedBox(height:10), OutlinedButton.icon(onPressed:_tambah, icon: const Icon(Icons.add_circle_outline_rounded,size:18), label: Text('Tambah Anggota', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w700,fontSize:13.5)), style: OutlinedButton.styleFrom(foregroundColor:_primary, side: BorderSide(color:_primary.withValues(alpha:0.4),width:1.5), padding: const EdgeInsets.symmetric(vertical:14), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height:24), _field(ctrl:_ketUmumCtrl,label:'Keterangan Umum (Opsional)',hint:'Catatan tambahan...',icon:Icons.notes_rounded, maxLines:3),
        const SizedBox(height:32), SizedBox(width:double.infinity, child: ElevatedButton(onPressed:_saving?null:_save, style: ElevatedButton.styleFrom(backgroundColor:_primary,foregroundColor:Colors.white, padding: const EdgeInsets.symmetric(vertical:16), shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation:2), child: _saving? const SizedBox(height:20,width:20, child:CircularProgressIndicator(strokeWidth:2.5,color:Colors.white)): Text(_isEdit?'Perbarui':'Simpan Catatan Keluarga', style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w700))))
      ])),
    );
  }

  Widget _buildAnggota(int index){
    final a=_anggota[index];
    return Container(margin: const EdgeInsets.only(bottom:12), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:a.namaCtrl.text.isNotEmpty? const Color(0xFFFECACA):const Color(0xFFE2E8F0)),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:0.04),blurRadius:6,offset:const Offset(0,2))]), child: Theme(data: ThemeData(dividerColor:Colors.transparent), child: ExpansionTile(
      initiallyExpanded: index==0,
      tilePadding: const EdgeInsets.symmetric(horizontal:14,vertical:4),
      childrenPadding: const EdgeInsets.fromLTRB(14,0,14,16),
      leading: Container(width:32,height:32, decoration:BoxDecoration(color: a.namaCtrl.text.isNotEmpty? _primary:const Color(0xFFF1F5F9), shape:BoxShape.circle), child: Center(child: Text('${index+1}', style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w800,color:a.namaCtrl.text.isNotEmpty?Colors.white:const Color(0xFF64748B))))),
      title: Text(a.namaCtrl.text.isEmpty? 'Anggota ${index+1}':a.namaCtrl.text, style:GoogleFonts.plusJakartaSans(fontWeight:FontWeight.w700,fontSize:14,color:const Color(0xFF0F172A))),
      subtitle: Text('${a.jk} • ${a.statusKawin} • ${a.pendidikan}', style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B))),
      trailing: Row(mainAxisSize:MainAxisSize.min, children:[if(_anggota.length>1) GestureDetector(onTap:()=>_hapus(index), child: Container(padding: const EdgeInsets.all(4), decoration:BoxDecoration(color:Colors.red.withValues(alpha:0.08),shape:BoxShape.circle), child: Icon(Icons.close_rounded,size:14,color:Colors.red[400]))), const SizedBox(width:8), const Icon(Icons.expand_more_rounded)]),
      children:[
        _field(ctrl:a.namaCtrl,label:'Nama Anggota',hint:'Nama lengkap',icon:Icons.person_outline_rounded, validator:(v)=> v==null||v.trim().isEmpty?'Wajib':null),
        const SizedBox(height:10), Row(children:[Expanded(child:_dropdownSimple(label:'L/P',value:a.jk,items:['L','P'],onChanged:(v)=>setState(()=>a.jk=v!))), const SizedBox(width:8), Expanded(child:_dropdownSimple(label:'Status Kawin',value:a.statusKawin,items:['Kawin','Belum Kawin','Janda','Duda'],onChanged:(v)=>setState(()=>a.statusKawin=v!))), const SizedBox(width:8), Expanded(child:_dropdownSimple(label:'Agama',value:a.agama,items:['Islam','Kristen','Katolik','Hindu','Budha','Konghucu','Kepercayaan','Lain-lain'],onChanged:(v)=>setState(()=>a.agama=v!)))]),
        const SizedBox(height:10), Row(children:[Expanded(child:_field(ctrl:a.tempatCtrl,label:'Tempat Lahir',hint:'Tasikmalaya',icon:Icons.place_outlined)), const SizedBox(width:8), Expanded(child:_field(ctrl:a.ttlCtrl,label:'Tgl/Bln/Th Lahir/Umur',hint:'12-05-1990 / 35 th',icon:Icons.cake_outlined))]),
        const SizedBox(height:10), Row(children:[Expanded(child:_dropdownSimple(label:'Pendidikan',value:a.pendidikan,items:['Tidak Tamat SD','SD/MI','SMP/Sederajat','SMA/SMK/Sederajat','Diploma','S1','S2','S3'],onChanged:(v)=>setState(()=>a.pendidikan=v!))), const SizedBox(width:8), Expanded(child:_field(ctrl:a.pekerjaanCtrl,label:'Pekerjaan',hint:'Wiraswasta',icon:Icons.work_outline_rounded))]),
        const SizedBox(height:10), _field(ctrl:a.khususCtrl,label:'Berkebutuhan Khusus',hint:'Tidak / Ya - keterangan',icon:Icons.accessibility_rounded),
        const SizedBox(height:12), Container(padding: const EdgeInsets.all(12), decoration:BoxDecoration(color:const Color(0xFFF8FAFC),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('Kegiatan PKK yang Diikuti (8 kolom)', style:GoogleFonts.plusJakartaSans(fontSize:12,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), const SizedBox(height:8), Wrap(spacing:8,runSpacing:8, children:[_checkChip('Pancasila',a.pancasila,(v)=>setState(()=>a.pancasila=v)),_checkChip('Gotong Royong',a.gotong,(v)=>setState(()=>a.gotong=v)),_checkChip('Pendidikan',a.didik,(v)=>setState(()=>a.didik=v)),_checkChip('Koperasi',a.koperasi,(v)=>setState(()=>a.koperasi=v)),_checkChip('Pangan',a.pangan,(v)=>setState(()=>a.pangan=v)),_checkChip('Sandang',a.sandang,(v)=>setState(()=>a.sandang=v)),_checkChip('Kesehatan',a.kesehatan,(v)=>setState(()=>a.kesehatan=v)),_checkChip('Perencanaan',a.perencanaan,(v)=>setState(()=>a.perencanaan=v))])])),
        const SizedBox(height:10), _field(ctrl:a.ketCtrl,label:'Keterangan',hint:'Opsional',icon:Icons.notes_rounded, maxLines:2),
      ],
    )));
  }

  Widget _checkChip(String label, bool val, ValueChanged<bool> onChanged)=> GestureDetector(onTap:(){ HapticFeedback.selectionClick(); onChanged(!val); }, child: AnimatedContainer(duration: const Duration(milliseconds:180), padding: const EdgeInsets.symmetric(horizontal:10,vertical:6), decoration:BoxDecoration(color:val? const Color(0xFFDC2626):Colors.white, borderRadius:BorderRadius.circular(20), border:Border.all(color:val? const Color(0xFFDC2626):const Color(0xFFE2E8F0))), child: Row(mainAxisSize:MainAxisSize.min, children:[if(val) const Padding(padding:EdgeInsets.only(right:4), child: Icon(Icons.check_circle_rounded,size:12,color:Colors.white)), Text(label, style:GoogleFonts.plusJakartaSans(fontSize:11.5,fontWeight: val?FontWeight.w700:FontWeight.w500, color: val?Colors.white:const Color(0xFF475569)))])));

  Widget _section(IconData icon,String title,String sub){ return Row(children:[Container(padding: const EdgeInsets.all(9), decoration:BoxDecoration(color:_primaryLight,borderRadius:BorderRadius.circular(12)), child: Icon(icon,size:18,color:_primary)), const SizedBox(width:12), Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(title, style:GoogleFonts.plusJakartaSans(fontSize:15,fontWeight:FontWeight.w800,color:const Color(0xFF0F172A))), Text(sub, style:GoogleFonts.plusJakartaSans(fontSize:11.5,color:const Color(0xFF64748B)))])]); }
  Widget _field({required TextEditingController ctrl,required String label,required String hint,required IconData icon, String? Function(String?)? validator, int maxLines=1})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), child: TextFormField(controller:ctrl,validator:validator,maxLines:maxLines, style:GoogleFonts.plusJakartaSans(fontSize:14), decoration:InputDecoration(labelText:label,hintText:hint,prefixIcon:Icon(icon,size:18,color:_primary), hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:Colors.grey[400]), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal:14,vertical:14))));
  Widget _dropdown({required String label,required String value,required List<String> items,required ValueChanged<String?> onChanged,required IconData icon})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), padding: const EdgeInsets.symmetric(horizontal:14,vertical:2), child: DropdownButtonFormField<String>(initialValue:value,isExpanded:true,icon:const Icon(Icons.keyboard_arrow_down_rounded,color:Color(0xFF64748B)), decoration:InputDecoration(labelText:label,prefixIcon:Icon(icon,size:18,color:_primary), labelStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding:EdgeInsets.zero), items:items.map((i)=>DropdownMenuItem(value:i, child: Text(i, style:GoogleFonts.plusJakartaSans(fontSize:13.5)))).toList(), onChanged:onChanged));
  Widget _dropdownSimple({required String label,required String value,required List<String> items,required ValueChanged<String?> onChanged})=> Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFE2E8F0))), padding: const EdgeInsets.symmetric(horizontal:10,vertical:2), child: DropdownButtonFormField<String>(initialValue:value,isExpanded:true, decoration:InputDecoration(labelText:label, labelStyle:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF64748B)), border:InputBorder.none,enabledBorder:InputBorder.none,focusedBorder:InputBorder.none, contentPadding:EdgeInsets.zero), items:items.map((i)=>DropdownMenuItem(value:i, child: Text(i, style:GoogleFonts.plusJakartaSans(fontSize:12)))).toList(), onChanged:onChanged));
}

class _AnggotaState{
  final TextEditingController namaCtrl, tempatCtrl, ttlCtrl, pekerjaanCtrl, khususCtrl, ketCtrl;
  String statusKawin='Kawin', jk='P', agama='Islam', pendidikan='SMA/SMK/Sederajat';
  bool pancasila=false, gotong=false, didik=false, koperasi=false, pangan=false, sandang=false, kesehatan=false, perencanaan=false;
  _AnggotaState(): namaCtrl=TextEditingController(), tempatCtrl=TextEditingController(), ttlCtrl=TextEditingController(), pekerjaanCtrl=TextEditingController(), khususCtrl=TextEditingController(), ketCtrl=TextEditingController();
  _AnggotaState.fromModel(DasawismaCatatanKeluargaItem m): namaCtrl=TextEditingController(text:m.namaAnggota), tempatCtrl=TextEditingController(text:m.tempatLahir), ttlCtrl=TextEditingController(text:m.tanggalLahirUmur), pekerjaanCtrl=TextEditingController(text:m.pekerjaan), khususCtrl=TextEditingController(text:m.berkebutuhanKhusus), ketCtrl=TextEditingController(text:m.keterangan) { statusKawin=m.statusPerkawinan; jk=m.jenisKelamin; agama=m.agama; pendidikan=m.pendidikan; pancasila=m.penghayatanPancasila; gotong=m.gotongRoyong; didik=m.pendidikanKeterampilan; koperasi=m.pengembanganKoperasi; pangan=m.pangan; sandang=m.sandang; kesehatan=m.kesehatan; perencanaan=m.perencanaanSehat; }
  void dispose(){ namaCtrl.dispose(); tempatCtrl.dispose(); ttlCtrl.dispose(); pekerjaanCtrl.dispose(); khususCtrl.dispose(); ketCtrl.dispose(); }
}
