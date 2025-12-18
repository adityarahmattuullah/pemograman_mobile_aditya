class Pengeluaran {
  String id;
  String nama; // Contoh: "Beli Deterjen"
  String tanggal;
  double jumlah; // Contoh: 50000

  Pengeluaran({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.jumlah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tanggal': tanggal,
      'jumlah': jumlah,
    };
  }

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      nama: map['nama'],
      tanggal: map['tanggal'],
      jumlah: map['jumlah'],
    );
  }
}