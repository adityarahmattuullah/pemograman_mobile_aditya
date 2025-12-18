import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; //
import '../models/layanan_model.dart';

class MasterLayananPage extends StatefulWidget {
  const MasterLayananPage({super.key});
  @override
  State<MasterLayananPage> createState() => _MasterLayananPageState();
}

class _MasterLayananPageState extends State<MasterLayananPage> {
  List<Layanan> _listLayanan = [];
  List<Layanan> _filteredList = [];
  final _namaC = TextEditingController();
  final _hargaC = TextEditingController();
  final _searchC = TextEditingController();
  String _satuanTerpilih = "Kg";

  @override
  void initState() {
    super.initState();
    _loadLayanan();
  }

  // --- FUNGSI LOAD DATA ---
  Future<void> _loadLayanan() async {
    final prefs = await SharedPreferences.getInstance(); //
    final String? data = prefs.getString('master_layanan');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _listLayanan = decoded.map((e) => Layanan.fromMap(e)).toList();
        _filteredList = _listLayanan;
      });
    }
  }

  // --- FUNGSI PENCARIAN ---
  void _filterLayanan(String query) {
    setState(() {
      _filteredList = _listLayanan
          .where((l) => l.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- NOTIFIKASI MODERN ---
  void _showCoolToast(String title, String sub, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: Icon(isError ? Icons.delete_outline : Icons.done_all, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _simpanKeStorage() async {
    final prefs = await SharedPreferences.getInstance(); //
    await prefs.setString('master_layanan', json.encode(_listLayanan.map((e) => e.toMap()).toList()));
    _filterLayanan(_searchC.text);
  }

  void _prosesSimpan({int? index}) {
    if (_namaC.text.isEmpty || _hargaC.text.isEmpty) return;
    final data = Layanan(nama: _namaC.text, harga: double.parse(_hargaC.text), satuan: _satuanTerpilih);
    setState(() {
      if (index == null) { _listLayanan.add(data); } 
      else { _listLayanan[index] = data; }
    });
    _simpanKeStorage();
    Navigator.pop(context);
    _showCoolToast(index == null ? "Berhasil!" : "Updated!", "Data layanan telah diperbarui.");
  }

  IconData _getIcon(String name) {
    String n = name.toLowerCase();
    if (n.contains("setrika")) return Icons.iron;
    if (n.contains("cuci")) return Icons.local_laundry_service;
    if (n.contains("sepatu")) return Icons.ice_skating;
    if (n.contains("bed")) return Icons.bed;
    if (n.contains("karpet")) return Icons.layers;
    return Icons.dry_cleaning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // --- HEADER MODERN (Tanpa Angka Total) ---
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Master Layanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.local_laundry_service, color: Colors.white24, size: 100),
                ),
              ),
            ),
          ),

          // --- SEARCH BAR ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                ),
                child: TextField(
                  controller: _searchC,
                  onChanged: _filterLayanan,
                  decoration: const InputDecoration(
                    hintText: "Cari layanan...",
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // --- LIST LAYANAN ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = _filteredList[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
                        child: Icon(_getIcon(item.nama), color: Colors.blue.shade800),
                      ),
                      title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("Rp ${item.harga.toInt()} / ${item.satuan}", style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blue), onPressed: () => _showForm(index: i)),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                            onPressed: () {
                              setState(() => _listLayanan.removeAt(i));
                              _simpanKeStorage();
                              _showCoolToast("Dihapus!", "Layanan berhasil dibuang.", isError: true);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _filteredList.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Layanan Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _showForm({int? index}) {
    if (index != null) {
      _namaC.text = _listLayanan[index].nama;
      _hargaC.text = _listLayanan[index].harga.toInt().toString();
      _satuanTerpilih = _listLayanan[index].satuan;
    } else {
      _namaC.clear(); _hargaC.clear(); _satuanTerpilih = "Kg";
    }

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text(index == null ? "Tambah Layanan" : "Edit Layanan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernField(_namaC, "Nama Layanan", Icons.local_offer),
              const SizedBox(height: 15),
              _buildModernField(_hargaC, "Harga (Rp)", Icons.payments, type: TextInputType.number),
              const SizedBox(height: 25),
              const Text("Satuan Unit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ["Kg", "Pcs"].map((s) {
                  bool isSel = _satuanTerpilih == s;
                  return GestureDetector(
                    onTap: () => setDialogState(() => _satuanTerpilih = s),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.blue.shade900 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(s, style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () => _prosesSimpan(index: index),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}