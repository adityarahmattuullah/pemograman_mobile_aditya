// lib/data/feedback_data.dart

Map<String, Map<String, dynamic>> feedbackData = {};

/// Simpan feedback. rating disimpan sebagai int (1..5)
void addFeedback(String dosenName, String studentName, int rating, String feedback) {
  final String id = DateTime.now().toIso8601String();
  feedbackData[id] = {
    'id': id,
    'dosenName': dosenName,
    'studentName': studentName,
    'rating': rating,
    'feedback': feedback,
    'date': DateTime.now().toLocal().toString().substring(0, 16), // format singkat
  };
}

/// Ambil semua feedback untuk dosen tertentu (urut terbaru dulu)
List<Map<String, dynamic>> getFeedbackForDosen(String dosenName) {
  final list = feedbackData.values
      .where((fb) => fb['dosenName'] == dosenName)
      .toList();

  // sort by id (iso timestamp) descending -> terbaru di depan
  list.sort((a, b) => (b['id'] as String).compareTo(a['id'] as String));
  return list;
}

/// Hitung rata-rata rating (kembalikan double)
double getAverageRating(String dosenName) {
  final list = getFeedbackForDosen(dosenName);
  if (list.isEmpty) return 0;
  final total = list.fold<int>(0, (sum, fb) => sum + (fb['rating'] as int));
  return total / list.length;
}

/// Hapus feedback berdasarkan id
void deleteFeedback(String id) {
  feedbackData.remove(id);
}
