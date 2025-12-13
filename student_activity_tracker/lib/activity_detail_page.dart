import 'package:flutter/material.dart';
import '../model/activity_model.dart';
import 'add_activity_page.dart';

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;
  final int index;

  const ActivityDetailPage({
    super.key,
    required this.activity,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Hapus Aktivitas"),
                    content: const Text(
                        "Apakah Anda yakin ingin menghapus aktivitas ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Hapus"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                Navigator.pop(context, "delete");
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Nama Aktivitas:", style: header),
            Text(activity.name, style: content),
            const SizedBox(height: 15),

            Text("Kategori:", style: header),
            Text(activity.category, style: content),
            const SizedBox(height: 15),

            Text("Durasi:", style: header),
            Text("${activity.duration} Jam", style: content),
            const SizedBox(height: 15),

            Text("Status:", style: header),
            Text(activity.isCompleted ? "Selesai" : "Belum", style: content),
            const SizedBox(height: 15),

            Text("Catatan:", style: header),
            Text(activity.notes.isEmpty ? "-" : activity.notes, style: content),
            const SizedBox(height: 30),

            FilledButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddActivityPage(isEdit: true, activity: activity),
                  ),
                );

                if (result is Activity) {
                  Navigator.pop(context, result);
                }
              },
              child: const Text("Edit Aktivitas"),
            )
          ],
        ),
      ),
    );
  }

  TextStyle get header =>
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  TextStyle get content => const TextStyle(fontSize: 16);
}
