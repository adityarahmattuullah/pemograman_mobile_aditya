import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pengeluaran_model.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});
  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  List<Pengeluaran> _listPengeluaran = [];
  final _namaC = TextEditingController();
  final _jumlahC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- 1. FUNGSI FORMAT ANGKA (Contoh: 100.000) ---
  String _formatNumber(dynamic value) {
    if (value == null) return "0";
    String stringValue = value.toString().split('.')[0]; // Ambil angka bulat saja
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return stringValue.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('data_pengeluaran');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _listPengeluaran = decoded.map((e) => Pengeluaran.fromMap(e)).toList();
      });
    }
  }

  // --- 2. FUNGSI SIMPAN (Kunci: 'data_pengeluaran') ---
  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan field di toMap() menggunakan key 'nominal' agar dibaca Dashboard
    await prefs.setString('data_pengeluaran', json.encode(_listPengeluaran.map((e) => e.toMap()).toList()));
  }

  void _tambahPengeluaran() {
    if (_namaC.text.isEmpty || _jumlahC.text.isEmpty) return;

    final baru = Pengeluaran(
      id: DateTime.now().toString(),
      nama: _namaC.text,
      tanggal: DateTime.now().toString().substring(0, 10),
      jumlah: double.parse(_jumlahC.text),
    );

    setState(() => _listPengeluaran.add(baru));
    _simpanData();
    _namaC.clear(); 
    _jumlahC.clear();
    Navigator.pop(context); // Tutup dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil dicatat"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  void _hapus(int index) {
    setState(() => _listPengeluaran.removeAt(index));
    _simpanData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data dihapus"), backgroundColor: Colors.grey, behavior: SnackBarBehavior.floating),
    );
  }

  void _showInputForm() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Catat Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(_namaC, "Nama Pengeluaran (mis: Listrik)", Icons.label_outline),
            const SizedBox(height: 15),
            _buildInput(_jumlahC, "Biaya (Rp)", Icons.money_off, type: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: _tambahPengeluaran, 
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red.shade300),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = _listPengeluaran.fold(0, (sum, item) => sum + item.jumlah);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Pengeluaran Operasional"), centerTitle: true),
      body: Column(
        children: [
          // --- HEADER CARD (Total Pengeluaran Ber-Titik) ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.red.shade800, Colors.red.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.red.shade200, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Keluar", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                  "Rp ${_formatNumber(totalExpense.toInt())}", //
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: _listPengeluaran.isEmpty
                ? Center(child: Text("Belum ada data", style: TextStyle(color: Colors.grey.shade400)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _listPengeluaran.length,
                    itemBuilder: (context, i) {
                      final item = _listPengeluaran[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: Icon(Icons.receipt, color: Colors.red.shade700)),
                          title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.tanggal),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Rp ${_formatNumber(item.jumlah.toInt())}", //
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800),
                              ),
                              IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _hapus(i)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInputForm,
        backgroundColor: Colors.red.shade700,
        label: const Text("Catat Baru", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}