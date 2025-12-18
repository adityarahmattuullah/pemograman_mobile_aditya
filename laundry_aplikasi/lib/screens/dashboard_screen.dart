import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart';
import 'input_pesanan_screen.dart';
import 'hasil_pesanan_screen.dart';
import 'laporan_screen.dart';
import 'master_layanan_screen.dart';
import 'pengeluaran_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Pesanan> _listPesanan = [];
  double _totalPengeluaran = 0;
  int _jumlahMasterLayanan = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- FORMAT ANGKA DENGAN TITIK ---
  String _formatNumber(dynamic value) {
    if (value == null) return "0";
    String stringValue = value.toString().split('.')[0];
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return stringValue.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  // --- UCAPAN WAKTU DINAMIS ---
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi";
    if (hour < 17) return "Selamat Siang";
    return "Selamat Sore";
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil Data Pesanan
    final String? dataPesanan = prefs.getString('data_laundry');
    if (dataPesanan != null) {
      final List decoded = json.decode(dataPesanan);
      setState(() {
        _listPesanan = decoded.map((e) => Pesanan.fromMap(e)).toList();
        _listPesanan.sort((a, b) => b.id.compareTo(a.id));
      });
    }

    // Ambil Data Pengeluaran
    final String? dataPengeluaran = prefs.getString('data_pengeluaran');
    double totalKeluar = 0;
    if (dataPengeluaran != null) {
      final List decodedKeluar = json.decode(dataPengeluaran);
      for (var item in decodedKeluar) {
        totalKeluar += (item['jumlah'] ?? item['nominal'] ?? 0);
      }
    }

    // Ambil Data Master Layanan
    final String? dataLayanan = prefs.getString('master_layanan');
    if (dataLayanan != null) {
      _jumlahMasterLayanan = json.decode(dataLayanan).length;
    }

    setState(() {
      _totalPengeluaran = totalKeluar;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Perhitungan Saldo
    int proses = _listPesanan.where((p) => !p.isLunas).length;
    int selesai = _listPesanan.where((p) => p.isLunas).length;
    double totalMasuk = _listPesanan.fold(0, (sum, item) {
      double cash = item.dp;
      if (item.isLunas) cash += (item.totalHarga - item.dp);
      return sum + cash;
    });
    double saldoKasNeto = totalMasuk - _totalPengeluaran;

    // Deteksi Mode Gelap untuk warna teks kontras
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Adaptasi Warna Latar
      appBar: AppBar(
        title: const Text("GO-CLEAN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E1B4B)),
              accountName: const Text("Aditya Rahmattullah", style: TextStyle(fontWeight: FontWeight.bold)), //
              accountEmail: const Text("Admin Kasir Laundry Jambi"),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF1E1B4B))),
            ),
            _menuTile(Icons.add_shopping_cart_rounded, "Input Pesanan", const InputPesananPage()),
            _menuTile(Icons.history_rounded, "Riwayat Transaksi", HasilPesananPage(list: _listPesanan)),
            const Divider(),
            _menuTile(Icons.analytics_rounded, "Laporan Keuangan", LaporanPage(listPesanan: _listPesanan)),
            _menuTile(Icons.money_off_rounded, "Catat Pengeluaran", const PengeluaranPage()),
            const Divider(),
            _menuTile(Icons.settings_suggest_rounded, "Master Layanan", const MasterLayananPage()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_getGreeting()},", style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            Text("Aditya Rahmattullah", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 20),
            
            // --- 1. TOTAL KAS (BESAR DI ATAS) ---
            _bigStatCard("Total Saldo Kas (Neto)", "Rp ${_formatNumber(saldoKasNeto.toInt())}", Icons.account_balance_wallet_rounded),
            
            const SizedBox(height: 20),

            // --- 2. BARIS STATISTIK (3 KOLOM) ---
            Row(
              children: [
                Expanded(child: _smallStatCard(context, "Layanan", _formatNumber(_jumlahMasterLayanan), Colors.purple, Icons.local_laundry_service)),
                const SizedBox(width: 10),
                Expanded(child: _smallStatCard(context, "Proses", _formatNumber(proses), Colors.orange, Icons.hourglass_top)),
                const SizedBox(width: 10),
                Expanded(child: _smallStatCard(context, "Selesai", _formatNumber(selesai), Colors.green, Icons.task_alt)),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text("Akses Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(context, Icons.add_box, "Pesanan", const Color(0xFF4338CA), const InputPesananPage()),
                _quickAction(context, Icons.category, "Master", Colors.indigo, const MasterLayananPage()),
                _quickAction(context, Icons.payments, "Laporan", Colors.blueGrey, LaporanPage(listPesanan: _listPesanan)),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Analisis Pesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildChart(context, proses, selesai, _jumlahMasterLayanan),

            const SizedBox(height: 30),
            const Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildRecentTransactions(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER DENGAN ADAPTASI TEMA ---

  Widget _bigStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF4338CA).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 45),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard(BuildContext context, String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Mengikuti Tema Kartu
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => page)).then((_) => _loadData()),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    var recent = _listPesanan.take(3).toList();
    if (recent.isEmpty) return const Center(child: Text("Belum ada transaksi"));
    
    return Column(
      children: recent.map((item) => Card(
        color: Theme.of(context).cardColor,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.isLunas ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Icon(Icons.receipt_long, color: item.isLunas ? Colors.green : Colors.orange, size: 20),
          ),
          title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.layanan, style: const TextStyle(fontSize: 12)),
          trailing: Text("Rp ${_formatNumber(item.totalHarga.toInt())}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      )).toList(),
    );
  }

  Widget _buildChart(BuildContext context, int p, int s, int l) {
    int max = [p, s, l].reduce((a, b) => a > b ? a : b);
    if (max == 0) max = 1;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(context, l, Colors.purple, "Layanan", max),
          _bar(context, p, Colors.orange, "Proses", max),
          _bar(context, s, Colors.green, "Selesai", max),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, int v, Color c, String label, int max) {
    double h = (v / max) * 100;
    return Column(
      children: [
        Text(_formatNumber(v), style: TextStyle(fontWeight: FontWeight.bold, color: c)),
        const SizedBox(height: 5),
        Container(width: 35, height: h + 10, decoration: BoxDecoration(color: c.withOpacity(0.8), borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4338CA)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => page)).then((_) => _loadData());
      },
    );
  }
}