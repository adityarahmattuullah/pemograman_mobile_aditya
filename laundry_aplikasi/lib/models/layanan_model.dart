class Layanan {
  String nama;
  double harga;
  String satuan; // Tambahkan ini: "Kg" atau "Pcs"

  Layanan({
    required this.nama,
    required this.harga,
    required this.satuan,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'satuan': satuan,
    };
  }

  factory Layanan.fromMap(Map<String, dynamic> map) {
    return Layanan(
      nama: map['nama'],
      harga: map['harga'],
      satuan: map['satuan'] ?? "Kg", // Default ke Kg jika data lama kosong
    );
  }
}