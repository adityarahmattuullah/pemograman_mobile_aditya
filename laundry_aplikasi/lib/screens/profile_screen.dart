import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Menghubungkan ke themeNotifier di main.dart
import 'login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- FUNGSI LOGOUT ---
  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (c) => const LoginPage()), 
        (route) => false
      );
    }
  }

  // --- FUNGSI GANTI TEMA ---
  void _toggleTheme(bool isDark) async {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark); // Simpan pilihan tema
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengikuti warna tema sistem
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER GRADIENT INDIGO ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "PROFIL SAYA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.person, size: 70, color: Color(0xFF1E1B4B)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // --- DATA DIRI ---
            Text(
              "Aditya Rahmattullah",
              style: TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).textTheme.bodyLarge?.color
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "NIM: 701230073 • Kelas 5B",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            // --- KARTU INFO AKADEMIK ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Expanded(child: _infoCard(context, "Status", "Mahasiswa")),
                  const SizedBox(width: 15),
                  Expanded(child: _infoCard(context, "Prodi", "Sistem Informasi")),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SECTION: KONTAK ---
            _buildSectionTitle("Informasi Kontak"),
            _buildMenuContainer(context, [
              _menuItem(context, Icons.email_outlined, "aditya.rahmattullah@student.com", Colors.blue),
              _menuItem(context, Icons.phone_android_outlined, "+62 822-XXXX-XXXX", Colors.green),
            ]),

            const SizedBox(height: 20),

            // --- SECTION: PENGATURAN (TAMBAHAN FITUR TEMA) ---
            _buildSectionTitle("Pengaturan Aplikasi"),
            _buildMenuContainer(context, [
              // TOMBOL TEMA TERANG / GELAP
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, child) {
                  bool isDark = mode == ThemeMode.dark;
                  return SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: isDark ? Colors.amber : Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      isDark ? "Mode Gelap Aktif" : "Mode Terang Aktif",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: isDark,
                    onChanged: (v) => _toggleTheme(v),
                  );
                },
              ),
              const Divider(indent: 20, endIndent: 20),
              // TOMBOL LOGOUT
              ListTile(
                onTap: () => _handleLogout(context),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                title: const Text(
                  "Keluar Aplikasi",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
              ),
            ]),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UI HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildMenuContainer(BuildContext context, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(children: items),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
    );
  }
}