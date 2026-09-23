import 'package:flutter/material.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
import 'data_keluarga_dasawisma_form_screen.dart';

class KeluargaListScreen extends StatefulWidget {
  final bool embedded;
  final int initialIndex;
  const KeluargaListScreen({super.key, this.embedded = false, this.initialIndex = 0});

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final _service = DataKeluargaDasawismaService();
  final _search = TextEditingController();
  late Future<List<DataKeluargaDasawisma>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getAll(query: _search.text);
    if (mounted) setState(() {});
  }

  Future<void> _open(DataKeluargaDasawisma? item) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DataKeluargaDasawismaFormScreen(data: item)),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: widget.embedded
            ? null
            : AppBar(title: const Text('Data KK')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _open(null),
          label: const Text('Tambah dari Keluarga Binaan'),
          icon: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _search,
                onChanged: (_) => _reload(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari kepala keluarga, Dusun, RT, atau RW',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DataKeluargaDasawisma>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Belum ada Data KK.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _open(item),
                          leading: const CircleAvatar(child: Icon(Icons.home)),
                          title: Text(item.namaKepalaRumahTangga),
                          subtitle: Text(
                            'KK ${item.nomorKk.isEmpty ? '-' : item.nomorKk} • '
                            '${item.dusun.isEmpty ? 'Dusun belum diisi' : item.dusun} • '
                            'RT ${item.rt}/RW ${item.rw}\n'
                            '${item.desa}, ${item.kecamatan} • ${item.jumlahLakiLaki + item.jumlahPerempuan} jiwa',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.edit_outlined),
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}
