// lib/pages/feedback_form_page.dart

import 'package:flutter/material.dart';
import '../data/feedback_data.dart';

class FeedbackFormPage extends StatefulWidget {
  final String? dosenName;

  const FeedbackFormPage({this.dosenName, super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _studentNameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan beri rating ⭐ terlebih dahulu")),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final dosen = widget.dosenName ?? "Umum";
    final student = _studentNameController.text.trim();
    final feedbackText = _feedbackController.text.trim();

    addFeedback(dosen, student, _rating, feedbackText);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback terkirim!")),
    );

    // kembali ke halaman sebelumnya (Detail Dosen akan memanggil setState())
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dosenName != null ? "Feedback untuk ${widget.dosenName}" : "Form Feedback"),
        backgroundColor: const Color(0xFF3A6EA5),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Mahasiswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _studentNameController,
                decoration: InputDecoration(
                  hintText: "Masukkan nama Anda",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              const Text("Rating Dosen (1–5)", style: TextStyle(fontSize: 16)),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                    onPressed: () => setState(() => _rating = i + 1),
                  );
                }),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Tulis komentar Anda...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Feedback tidak boleh kosong" : null,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A6EA5)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Kirim Feedback", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
