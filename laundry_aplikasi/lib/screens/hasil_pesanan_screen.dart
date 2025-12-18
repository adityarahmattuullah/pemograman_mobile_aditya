import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pesanan_model.dart';

class HasilPesananPage extends StatefulWidget {
  final List<Pesanan> list;
  const HasilPesananPage({super.key, required this.list});

  @override
  State<HasilPesananPage> createState() => _HasilPesananPageState();
}

class _HasilPesananPageState extends State<HasilPesananPage> {
  late List<Pesanan> _allData;
  List<Pesanan> _filteredList = [];
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allData = widget.list;
    _filteredList = _allData;
  }

  // --- FUNGSI FORMAT ANGKA (Contoh: 100.000) ---
  String _formatNumber(dynamic value) {
    if (value == null) return "0";
    String stringValue = value.toString().split('.')[0]; // Ambil angka bulat
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return stringValue.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  void _filterData(String query) {
    setState(() {
      _filteredList = _allData
          .where((item) =>
              item.nama.toLowerCase().contains(query.toLowerCase()) ||
              item.layanan.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showCoolNotif(String title, String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(msg, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editPesanan(int indexInFiltered) {
    Pesanan p = _filteredList[indexInFiltered];
    final namaC = TextEditingController(text: p.nama);
    final hpC = TextEditingController(text: p.noHp);
    final totalC = TextEditingController(text: p.totalHarga.toInt().toString());
    final dpC = TextEditingController(text: p.dp.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(namaC, "Nama Pelanggan", Icons.person),
              const SizedBox(height: 10),
              _buildEditField(hpC, "No. WhatsApp", Icons.phone_android, type: TextInputType.phone),
              const SizedBox(height: 10),
              _buildEditField(totalC, "Total Harga (Rp)", Icons.attach_money, type: TextInputType.number),
              const SizedBox(height: 10),
              _buildEditField(dpC, "DP (Rp)", Icons.wallet, type: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                int originalIndex = _allData.indexWhere((element) => element.id == p.id);
                if (originalIndex != -1) {
                  _allData[originalIndex].nama = namaC.text;
                  _allData[originalIndex].noHp = hpC.text;
                  _allData[originalIndex].totalHarga = double.tryParse(totalC.text) ?? p.totalHarga;
                  _allData[originalIndex].dp = double.tryParse(dpC.text) ?? p.dp;
                }
                _filterData(_searchC.text);
              });
              _saveToStorage();
              Navigator.pop(context);
              _showCoolNotif("Update Berhasil", "Data pesanan diperbarui.", Icons.save, Colors.blue.shade700);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // --- DESAIN STRUK PDF PREMIUM DENGAN FORMAT TITIK ---
  Future<void> _cetakStruk(Pesanan item) async {
    final pdf = pw.Document();
    double sisa = item.isLunas ? 0 : (item.totalHarga - item.dp);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, 
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(children: [
                    pw.Text("GO-CLEAN LAUNDRY", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Jambi, Indonesia", style: pw.TextStyle(fontSize: 9)),
                    pw.Text("-------------------------------------------------"),
                  ]),
                ),
                pw.SizedBox(height: 5),
                _rowStruk("Tanggal", item.tanggal),
                _rowStruk("Pelanggan", item.nama),
                _rowStruk("No. HP", item.noHp),
                pw.SizedBox(height: 5),
                pw.Text("- Detail Layanan -", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(item.layanan, style: pw.TextStyle(fontSize: 10))),
                    pw.Text("Rp ${_formatNumber(item.totalHarga.toInt())}", style: pw.TextStyle(fontSize: 10)), //
                  ],
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),
                _rowStruk("Total Harga", "Rp ${_formatNumber(item.totalHarga.toInt())}", isBold: true), //
                _rowStruk("Uang Muka (DP)", "Rp ${_formatNumber(item.dp.toInt())}"), //
                _rowStruk("Sisa Bayar", "Rp ${_formatNumber(sisa.toInt())}", isBold: sisa > 0), //
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Text(
                      item.isLunas ? "STATUS: LUNAS" : "STATUS: BELUM LUNAS",
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Center(
                  child: pw.Text(
                    "Terima kasih atas kunjungan Anda!", 
                    style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Struk_${item.nama}.pdf');
  }

  pw.Widget _rowStruk(String label, String val, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9)),
          pw.Text(val, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('data_laundry', json.encode(_allData.map((e) => e.toMap()).toList()));
  }

  void _hapusPesanan(int indexInFiltered) {
    Pesanan item = _filteredList[indexInFiltered];
    setState(() {
      _allData.removeWhere((element) => element.id == item.id);
      _filterData(_searchC.text);
    });
    _saveToStorage();
    _showCoolNotif("DIHAPUS", "Pesanan telah dihapus.", Icons.delete_sweep, Colors.red.shade700);
  }

  void _tandaiLunas(int indexInFiltered) {
    Pesanan item = _filteredList[indexInFiltered];
    setState(() {
      int originalIndex = _allData.indexWhere((element) => element.id == item.id);
      if (originalIndex != -1) _allData[originalIndex].isLunas = true;
      _filterData(_searchC.text);
    });
    _saveToStorage();
    _showCoolNotif("LUNAS", "Status pembayaran diperbarui.", Icons.verified, Colors.green.shade700);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Riwayat Transaksi"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchC,
                onChanged: _filterData,
                decoration: const InputDecoration(
                  hintText: "Cari nama atau layanan...",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(child: Text("Data tidak ditemukan"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, i) {
                      final item = _filteredList[i];
                      double sisaBayar = item.isLunas ? 0 : (item.totalHarga - item.dp);

                      return Container(
                        margin: const EdgeInsets.all(0),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isLunas ? Colors.green.shade50 : Colors.orange.shade50,
                              child: Text(
                                item.nama.isNotEmpty ? item.nama[0].toUpperCase() : "?",
                                style: TextStyle(
                                  color: item.isLunas ? Colors.green : Colors.orange, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item.layanan} • ${item.tanggal}", style: const TextStyle(fontSize: 11)),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(color: Colors.grey.shade50),
                                child: Column(
                                  children: [
                                    // --- TAMPILAN NOMINAL BER-TITIK DI LIST ---
                                    _detailRow("Total Tagihan", "Rp ${_formatNumber(item.totalHarga.toInt())}"),
                                    _detailRow("Uang Muka (DP)", "Rp ${_formatNumber(item.dp.toInt())}"),
                                    _detailRow("Sisa Bayar", "Rp ${_formatNumber(sisaBayar.toInt())}", 
                                        color: sisaBayar > 0 ? Colors.red : Colors.green),
                                    const Divider(),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _actionButton(icon: Icons.print, label: "Struk", color: Colors.purple, onTap: () => _cetakStruk(item)),
                                        _actionButton(icon: Icons.edit, label: "Edit", color: Colors.blue, onTap: () => _editPesanan(i)),
                                        if (!item.isLunas) _actionButton(icon: Icons.check, label: "Lunas", color: Colors.green, onTap: () => _tandaiLunas(i)),
                                        _actionButton(icon: Icons.delete_outline, label: "Hapus", color: Colors.red, onTap: () => _hapusPesanan(i)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}