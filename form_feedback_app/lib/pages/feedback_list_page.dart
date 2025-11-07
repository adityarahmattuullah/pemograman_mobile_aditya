// lib/pages/feedback_list_page.dart

import 'package:flutter/material.dart';
import '../data/feedback_data.dart';

class FeedbackListPage extends StatelessWidget {
  final String? dosenName;

  const FeedbackListPage({this.dosenName, super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackList = feedbackData.entries.map((e) {
      final v = e.value;
      return {
        'id': e.key,
        'dosenName': v['dosenName'],
        'studentName': v['studentName'] ?? 'Mahasiswa',
        'rating': (v['rating'] is int) ? v['rating'] : (v['rating'] as num).toInt(),
        'feedback': v['feedback'] ?? '',
        'date': v['date'] ?? '',
      };
    }).toList();

    final filtered = dosenName == null ? feedbackList : feedbackList.where((f) => f['dosenName'] == dosenName).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(dosenName == null ? "Daftar Semua Feedback" : "Feedback untuk $dosenName"),
        backgroundColor: const Color(0xFF3A6EA5),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text("Belum ada feedback"))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final fb = filtered[i];
                final int rating = (fb['rating'] ?? 0) as int;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(fb['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: List.generate(rating, (_) => const Icon(Icons.star, size: 18, color: Colors.amber))),
                      const SizedBox(height: 6),
                      Text(fb['feedback']),
                      const SizedBox(height: 6),
                      Text(fb['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                    trailing: dosenName == null ? Text(fb['dosenName'], style: const TextStyle(fontSize: 12)) : null,
                  ),
                );
              },
            ),
    );
  }
}
