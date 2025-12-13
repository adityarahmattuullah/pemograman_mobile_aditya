import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingForm extends StatefulWidget {
  final Function(ShoppingItem) onSubmit;

  const ShoppingForm({super.key, required this.onSubmit});

  @override
  State<ShoppingForm> createState() => _ShoppingFormState();
}

class _ShoppingFormState extends State<ShoppingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  String _category = 'Makanan';

  final categories = [
    'Makanan',
    'Minuman',
    'Elektronik',
    'Kebutuhan Rumah',
    'Lainnya'
  ];

  InputDecoration inputStyle(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tambah Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: inputStyle('Nama Item'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: inputStyle('Jumlah'),
              validator: (v) =>
                  v!.isEmpty || int.tryParse(v) == null ? 'Angka!' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: _category,
              decoration: inputStyle('Kategori'),
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Simpan'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                ShoppingItem(
                  name: _nameCtrl.text,
                  quantity: int.parse(_qtyCtrl.text),
                  category: _category,
                ),
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
