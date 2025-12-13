import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/storage_service.dart';
import '../widgets/shopping_form.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<ShoppingItem> items = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    items = await StorageService.load();
    setState(() {});
  }

  void saveData() => StorageService.save(items);

  int get bought => items.where((e) => e.isBought).length;
  int get notBought => items.where((e) => !e.isBought).length;

  Widget statCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Item'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ShoppingForm(
              onSubmit: (item) {
                setState(() {
                  items.add(item);
                  saveData();
                });
              },
            ),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                statCard('Sudah', bought, Colors.green, Icons.check_circle),
                const SizedBox(width: 12),
                statCard('Belum', notBought, Colors.red, Icons.shopping_cart),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Belum ada item',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (c, i) {
                      final item = items[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isBought,
                            onChanged: (v) {
                              setState(() {
                                item.isBought = v!;
                                saveData();
                              });
                            },
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: item.isBought
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Chip(
                                label: Text(item.category),
                                backgroundColor:
                                    Colors.green.withOpacity(0.15),
                              ),
                              const SizedBox(width: 8),
                              Text('Qty: ${item.quantity}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                items.removeAt(i);
                                saveData();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
