// lib/pages/dosen_detail_page.dart

import 'package:flutter/material.dart';
import '../models/dosen.dart';
import 'feedback_form_page.dart';
import '../data/feedback_data.dart';

class DosenDetailPage extends StatefulWidget {
  final Dosen dosen;
  const DosenDetailPage({super.key, required this.dosen});

  @override
  State<DosenDetailPage> createState() => _DosenDetailPageState();
}

class _DosenDetailPageState extends State<DosenDetailPage> {
  @override
  Widget build(BuildContext context) {
    final feedbackList = getFeedbackForDosen(widget.dosen.nama);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100), bottomRight: Radius.circular(100)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 75, backgroundImage: AssetImage(widget.dosen.foto)),
              const SizedBox(height: 10),
              Text(widget.dosen.nama, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
            ]),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              _buildInfoCard(Icons.badge, "NIP", widget.dosen.nip),
              const SizedBox(height: 10),
              _buildInfoCard(Icons.work, "Nama MK", widget.dosen.mk),
              const SizedBox(height: 10),
              _buildInfoCard(Icons.email, "Email", widget.dosen.email),
            ]),
          ),

          const SizedBox(height: 25),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: Text("Feedback Mahasiswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),

          if (feedbackList.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text("Belum ada feedback."))
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: feedbackList.map((fb) {
                final int rating = (fb['rating'] is int) ? fb['rating'] as int : (fb['rating'] as num).toInt();
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(fb['studentName'] ?? 'Mahasiswa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: List.generate(rating, (_) => const Icon(Icons.star, color: Colors.amber, size: 18))),
                      const SizedBox(height: 6),
                      Text(fb['feedback'] ?? ''),
                      const SizedBox(height: 6),
                      Text(fb['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                      showDialog(context: context, builder: (_) => AlertDialog(
                        title: const Text("Hapus Feedback"),
                        content: const Text("Yakin ingin menghapus feedback ini?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                          TextButton(onPressed: () {
                            deleteFeedback(fb['id']);
                            Navigator.pop(context);
                            setState(() {});
                          }, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                        ],
                      ));
                    }),
                  ),
                );
              }).toList()),
            ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackFormPage(dosenName: widget.dosen.nama)));
              setState(() {});
            }, icon: const Icon(Icons.feedback), label: const Text("Beri Feedback Dosen"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ),

          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home), label: const Text('Kembali ke Home'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).toInt()), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(children: [Icon(icon, color: Colors.blueAccent), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54))]))]),
    );
  }
}
