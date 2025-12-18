class Pesanan {
  String id, tanggal, nama, noHp, layanan;
  double dp, totalHarga;
  bool isLunas;

  Pesanan({
    required this.id, required this.tanggal, required this.nama,
    required this.noHp, required this.layanan, required this.dp,
    required this.totalHarga, required this.isLunas,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'tanggal': tanggal, 'nama': nama, 'noHp': noHp,
    'layanan': layanan, 'dp': dp, 'totalHarga': totalHarga, 'isLunas': isLunas
  };

  factory Pesanan.fromMap(Map<String, dynamic> map) => Pesanan(
    id: map['id'], tanggal: map['tanggal'], nama: map['nama'],
    noHp: map['noHp'], layanan: map['layanan'], dp: map['dp'],
    totalHarga: map['totalHarga'], isLunas: map['isLunas'],
  );
}