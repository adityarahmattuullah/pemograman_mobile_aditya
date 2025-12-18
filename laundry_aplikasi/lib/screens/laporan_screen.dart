import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart';
import '../models/pengeluaran_model.dart';

class LaporanPage extends StatefulWidget {
  final List<Pesanan> listPesanan;
  const LaporanPage({super.key, required this.listPesanan});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  List<Pengeluaran> _listPengeluaran = [];

  @override
  void initState() {
    super.initState();
    _loadPengeluaran();
  }

  // --- FUNGSI FORMAT ANGKA (Contoh: 100.000) ---
  String _formatNumber(dynamic value) {
    if (value == null) return "0";
    String stringValue = value.toString().split('.')[0]; // Ambil angka bulat
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return stringValue.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Future<void> _loadPengeluaran() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('data_pengeluaran');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() => _listPengeluaran = decoded.map((e) => Pengeluaran.fromMap(e)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Hitung Pemasukan (Cash In Real)
    double uangMasuk = widget.listPesanan.fold(0, (sum, item) {
      double cash = item.dp;
      if (item.isLunas) cash += (item.totalHarga - item.dp);
      return sum + cash;
    });

    // 2. Hitung Total Tagihan (Omzet Kotor)
    double totalOmzet = widget.listPesanan.fold(0, (sum, item) => sum + item.totalHarga);
    
    // 3. Hitung Piutang
    double piutang = totalOmzet - uangMasuk;

    // 4. Hitung Pengeluaran
    double totalPengeluaran = _listPengeluaran.fold(0, (sum, item) => sum + item.jumlah);

    // 5. Laba Bersih
    double labaBersih = uangMasuk - totalPengeluaran;
    bool isUntung = labaBersih >= 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Laporan Keuangan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kesehatan Bisnis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 15),

            // --- HERO CARD: LABA BERSIH ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUntung 
                    ? [const Color(0xFF0061FF), const Color(0xFF60EFFF)] 
                    : [const Color(0xFFD31027), const Color(0xFFEA384D)], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isUntung ? Colors.blue.withOpacity(0.4) : Colors.red.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Net Profit (Laba Bersih)", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Icon(isUntung ? Icons.trending_up : Icons.trending_down, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Rp ${_formatNumber(labaBersih.toInt())}", //
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isUntung ? "Arus Kas Positif" : "Perhatian: Pengeluaran Tinggi",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildProfitabilityBar(uangMasuk, totalPengeluaran),
            const SizedBox(height: 20),

            // --- GRID RINCIAN ---
            Row(
              children: [
                Expanded(child: _detailCard("Pemasukan", uangMasuk, Colors.green, Icons.arrow_downward)),
                const SizedBox(width: 15),
                Expanded(child: _detailCard("Pengeluaran", totalPengeluaran, Colors.red, Icons.arrow_upward)),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Aset Tertahan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 15),

            // --- KARTU PIUTANG ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15)),
                    child: Icon(Icons.pending_actions_rounded, color: Colors.orange.shade700, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Piutang (Belum Lunas)", style: TextStyle(color: Colors.grey)),
                      Text(
                        "Rp ${_formatNumber(piutang.toInt())}", //
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Grafik Rasio Keuangan
  Widget _buildProfitabilityBar(double income, double expense) {
    double total = income + expense;
    if (total == 0) return const SizedBox.shrink();
    double incomePct = income / total;
    double expensePct = expense / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rasio Keuangan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(flex: (incomePct * 100).toInt(), child: Container(color: Colors.green)),
                Expanded(flex: (expensePct * 100).toInt(), child: Container(color: Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${(incomePct * 100).toStringAsFixed(0)}% Masuk", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
            Text("${(expensePct * 100).toStringAsFixed(0)}% Keluar", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  // Widget: Kartu Detail Nominal
  Widget _detailCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 5),
          Text(
            "Rp ${_formatNumber(value.toInt())}", //
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}