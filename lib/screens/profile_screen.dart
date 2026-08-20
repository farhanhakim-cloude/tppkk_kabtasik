import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late Future<User> _future;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _future = _authService.getCurrentUser();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loggingOut = true);
    await _authService.logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }

          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: pink.withOpacity(0.15),
                  child: Icon(Icons.person, size: 48, color: pink),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(user.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Text(user.jabatan, style: TextStyle(color: Colors.grey[600])),
              ),
              const SizedBox(height: 24),

              Card(
                child: Column(
                  children: [
                    _InfoTile(icon: Icons.email, label: 'Email', value: user.email),
                    const Divider(height: 1),
                    _InfoTile(icon: Icons.location_on, label: 'Wilayah Tugas', value: user.wilayah),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _loggingOut
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Keluar', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pink = Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Icon(icon, color: pink),
      title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      subtitle: Text(value, style: const TextStyle(fontSize: 15)),
    );
  }
}