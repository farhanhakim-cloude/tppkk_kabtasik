import 'package:flutter/material.dart';
import '../models/kesehatan.dart';
import '../services/kesehatan_service.dart';
import 'kesehatan_form_screen.dart';

class KesehatanListScreen extends StatefulWidget {
  const KesehatanListScreen({super.key});

  @override
  State<KesehatanListScreen> createState() => _KesehatanListScreenState();
}

class _KesehatanListScreenState extends State<KesehatanListScreen>
    with SingleTickerProviderStateMixin {
  final _service = KesehatanService();
  late TabController _tabController;
  late Future<List<DataKesehatan>> _future;

  final _kategoriList = [
    KategoriKesehatan.ibuHamil,
    KategoriKesehatan.ibuMenyusui,
    KategoriKesehatan.balita,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _reload();
    });
    _future = _service.getAll(filter: _kategoriList[0]);
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(filter: _kategoriList[_tabController.index]);
    });
  }

  Future<void> _openForm({DataKesehatan? data}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KesehatanFormScreen(
          data: data,
          kategoriAwal: _kategoriList[_tabController.index],
        ),
      ),
    );
    if (result == true) _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kesehatan Ibu & Anak'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ibu Hamil'),
            Tab(text: 'Ibu Menyusui'),
            Tab(text: 'Balita'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<DataKesehatan>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final d = list[index];
              final isBalita = d.kategori == KategoriKesehatan.balita;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(
                      isBalita ? Icons.child_care : Icons.pregnant_woman,
                      color: primary,
                    ),
                  ),
                  title: Text(
                    isBalita ? d.namaAnak : d.namaIbu,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isBalita
                        ? 'Ibu: ${d.namaIbu} • Usia: ${d.usiaKehamilanAtauAnak} • Gizi: ${d.statusGizi}\nRT ${d.rt}/RW ${d.rw}'
                        : 'Usia kandungan/menyusui: ${d.usiaKehamilanAtauAnak}\nRT ${d.rt}/RW ${d.rw}',
                  ),
                  isThreeLine: true,
                  onTap: () => _openForm(data: d),
                ),
              );
            },
          );
        },
      ),
    );
  }
}