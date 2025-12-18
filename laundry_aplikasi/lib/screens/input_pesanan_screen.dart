import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart';
import '../models/layanan_model.dart';

class InputPesananPage extends StatefulWidget {
  const InputPesananPage({super.key});
  @override
  State<InputPesananPage> createState() => _InputPesananPageState();
}

class _InputPesananPageState extends State<InputPesananPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  final _namaC = TextEditingController();
  final _hpC = TextEditingController();
  final _dpC = TextEditingController();
  final _jumlahC = TextEditingController(text: "1.0"); 
  
  // Data & State
  List<Layanan> _listMasterLayanan = [];
  Layanan? _selectedLayanan;
  double _jumlah = 1.0; 
  bool _isLunas = false;

  @override
  void initState() {
    super.initState();
    _loadMasterLayanan();
  }

  // --- FUNGSI FORMAT ANGKA (Contoh: 100.000) ---
  String _formatNumber(dynamic value) {
    if (value == null) return "0";
    String stringValue = value.toString().split('.')[0]; // Ambil angka bulat
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return stringValue.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  // Load Data Master
  Future<void> _loadMasterLayanan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('master_layanan');
    
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _listMasterLayanan = decoded.map((e) => Layanan.fromMap(e)).toList();
        if (_listMasterLayanan.isNotEmpty) {
          _selectedLayanan = _listMasterLayanan[0];
        }
      });
    }
  }

  // Simpan Transaksi
  void _simpan() async {
    if (_listMasterLayanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Master Layanan Kosong!")));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('data_laundry');
    List list = data != null ? json.decode(data) : [];

    double total = _jumlah * (_selectedLayanan?.harga ?? 0);
    double dp = _dpC.text.isEmpty ? 0 : double.parse(_dpC.text);

    Pesanan baru = Pesanan(
      id: DateTime.now().toString(),
      tanggal: DateTime.now().toString().substring(0, 10),
      nama: _namaC.text, 
      noHp: _hpC.text, 
      layanan: _selectedLayanan!.nama, 
      dp: dp, 
      totalHarga: total, 
      isLunas: _isLunas,
    );

    list.add(baru.toMap());
    await prefs.setString('data_laundry', json.encode(list));

    if (mounted) _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, color: Colors.green.shade600, size: 50),
              ),
              const SizedBox(height: 20),
              const Text("Transaksi Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Data pesanan telah disimpan ke riwayat.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  child: const Text("KEMBALI KE DASHBOARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double estimasiTotal = _jumlah * (_selectedLayanan?.harga ?? 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Buat Pesanan Baru"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _listMasterLayanan.isEmpty 
      ? _buildEmptyState()
      : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOTAL HARGA (MODERN FORMAT BER-TITIK) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("Total Tagihan", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "Rp ${_formatNumber(estimasiTotal.toInt())}", // PENGGUNAAN FORMAT TITIK
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Informasi Pelanggan"),
                _buildCardContainer(
                  child: Column(
                    children: [
                      _buildInput(_namaC, "Nama Lengkap", Icons.person_outline),
                      const Divider(height: 20),
                      _buildInput(_hpC, "Nomor WhatsApp", Icons.phone_android_outlined, type: TextInputType.phone),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("Layanan & Berat"),
                _buildCardContainer(
                  child: Column(
                    children: [
                      // DROPDOWN LAYANAN (HARGA BER-TITIK)
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<Layanan>(
                          value: _selectedLayanan,
                          decoration: InputDecoration(
                            labelText: "Pilih Jenis Layanan",
                            prefixIcon: Icon(Icons.local_laundry_service_outlined, color: Colors.blue.shade700),
                            border: InputBorder.none,
                          ),
                          items: _listMasterLayanan.map((lay) {
                            return DropdownMenuItem<Layanan>(
                              value: lay,
                              child: Text("${lay.nama} (Rp ${_formatNumber(lay.harga.toInt())}/${lay.satuan})"), // PENGGUNAAN FORMAT TITIK
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedLayanan = v;
                              _jumlah = 1.0;
                              _jumlahC.text = "1.0";
                            });
                          },
                        ),
                      ),
                      const Divider(height: 30),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedLayanan?.satuan == "Kg" ? "Berat Cucian" : "Jumlah Barang",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                          Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _jumlahC,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 18),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              onChanged: (v) {
                                double? val = double.tryParse(v);
                                if (val != null && val >= 0) {
                                  setState(() => _jumlah = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue.shade700,
                          inactiveTrackColor: Colors.blue.shade100,
                          thumbColor: Colors.blue.shade900,
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _jumlah.clamp(0.1, 50.0),
                          min: 0.1, max: 50.0,
                          onChanged: (v) {
                            setState(() {
                              _jumlah = _selectedLayanan?.satuan == "Pcs" ? v.roundToDouble() : v;
                              _jumlahC.text = _selectedLayanan?.satuan == "Pcs" 
                                  ? _jumlah.toInt().toString() 
                                  : _jumlah.toStringAsFixed(1);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("Pembayaran"),
                _buildCardContainer(
                  child: Column(
                    children: [
                      _buildInput(_dpC, "Uang Muka / DP (Opsional)", Icons.account_balance_wallet_outlined, type: TextInputType.number),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: _isLunas ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            _isLunas ? "Status: LUNAS" : "Status: BELUM LUNAS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLunas ? Colors.green.shade800 : Colors.orange.shade800
                            ),
                          ),
                          value: _isLunas,
                          activeColor: Colors.green.shade700,
                          onChanged: (v) => setState(() => _isLunas = v),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                    onPressed: _simpan, 
                    child: const Text("SIMPAN TRANSAKSI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (v) => v!.isEmpty && label.contains("Nama") ? "Wajib diisi" : null,
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.blue.shade200),
          const SizedBox(height: 16),
          const Text("Layanan Belum Tersedia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tambahkan layanan di Master Layanan terlebih dahulu.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}