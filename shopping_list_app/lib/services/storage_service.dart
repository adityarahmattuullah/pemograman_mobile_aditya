import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class StorageService {
  static const String key = 'shopping_list';

  static Future<void> save(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  static Future<List<ShoppingItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data
        .map((e) => ShoppingItem.fromJson(jsonDecode(e)))
        .toList();
  }
}
