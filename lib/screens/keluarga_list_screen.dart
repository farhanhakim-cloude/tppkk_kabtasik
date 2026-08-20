import 'package:flutter/material.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'keluarga_form_screen.dart';

class KeluargaListScreen extends StatefulWidget {
  const KeluargaListScreen({super.key});

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final _service = KeluargaService();
  final _searchController = TextEditingController();
  late Future<List<Keluarga>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAll();
  }

  void _reload() {
    setState(() => _future = _service.getAll(query: _searchController.text));
  }

  Future<void> _openForm({Keluarga? keluarga}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeluargaFormScreen(keluarga: keluarga)),
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Keluarga')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama kepala keluarga...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Keluarga>>(
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final k = list[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: pink.withOpacity(0.1),
                          child: Icon(Icons.home, color: pink),
                        ),
                        title: Text(k.namaKepalaKeluarga, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${k.alamat}\nRT ${k.rt}/RW ${k.rw} • ${k.jumlahAnggota} anggota • ${k.pekerjaan}'),
                        isThreeLine: true,
                        onTap: () => _openForm(keluarga: k),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}