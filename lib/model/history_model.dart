class HistoryModel {
  final String namaMakanan;
  final List<String> bahan;
  final List<String> langkah;

  HistoryModel({
    required this.namaMakanan,
    required this.bahan,
    required this.langkah,
  });

  // Konversi ke Map (untuk Hive)
  Map<String, dynamic> toMap() {
    return {
      'namaMakanan': namaMakanan,
      'bahan': bahan,
      'langkah': langkah,
    };
  }

  // Buat dari Map (untuk Hive)
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      namaMakanan: map['namaMakanan'],
      bahan: List<String>.from(map['bahan']),
      langkah: List<String>.from(map['langkah']),
    );
  }
}
