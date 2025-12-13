import 'package:flutter/material.dart';
import '../models/note.dart';

class AddEditPage extends StatefulWidget {
  final Note? note;
  const AddEditPage({super.key, this.note});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _category = 'Kuliah';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!.title;
      _contentCtrl.text = widget.note!.content;
      _category = widget.note!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Catatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: ['Kuliah', 'Organisasi', 'Pribadi', 'Lain-lain']
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('SIMPAN'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      Note(
                        title: _titleCtrl.text,
                        content: _contentCtrl.text,
                        category: _category,
                        createdAt:
                            widget.note?.createdAt ?? DateTime.now(),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
