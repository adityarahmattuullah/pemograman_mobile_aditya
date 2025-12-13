import 'package:flutter/material.dart';
import '../model/activity_model.dart';

class AddActivityPage extends StatefulWidget {
  final bool isEdit;
  final Activity? activity;

  const AddActivityPage({
    super.key,
    this.isEdit = false,
    this.activity,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String? selectedCategory;
  double duration = 1;
  bool isCompleted = false;   // <-- ganti dari isDone

  final categories = ["Belajar", "Ibadah", "Olahraga", "Hiburan", "Lainnya"];

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.activity != null) {
      final a = widget.activity!;
      nameController.text = a.name;
      notesController.text = a.notes;
      selectedCategory = a.category;
      duration = a.duration;
      isCompleted = a.isCompleted;  // <-- perbaikan
    }
  }

  void save() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama aktivitas wajib diisi!")),
      );
      return;
    }

    final newActivity = Activity(
      name: nameController.text,
      duration: duration,
      isCompleted: isCompleted,   // <-- perbaikan
      notes: notesController.text,
      category: selectedCategory ?? "Lainnya",
    );

    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Aktivitas" : "Tambah Aktivitas"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Aktivitas",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori Aktivitas",
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
            const SizedBox(height: 20),

            Text("Durasi (Jam): ${duration.round()}"),
            Slider(
              value: duration,
              min: 1,
              max: 8,
              divisions: 7,
              label: "${duration.round()} Jam",
              onChanged: (v) => setState(() => duration = v),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Sudah Selesai"),
              value: isCompleted,    // <-- perbaikan
              onChanged: (v) => setState(() => isCompleted = v),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            FilledButton(
              onPressed: save,
              child: Text(widget.isEdit ? "Simpan Perubahan" : "Simpan Aktivitas"),
            )
          ],
        ),
      ),
    );
  }
}
