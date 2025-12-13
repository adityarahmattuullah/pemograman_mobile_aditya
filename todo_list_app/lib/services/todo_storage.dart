import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoStorage {
  static const String key = 'todos';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];

    List decoded = jsonDecode(data);
    return decoded.map((e) => Todo.fromMap(e)).toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(todos.map((e) => e.toMap()).toList());
    await prefs.setString(key, data);
  }
}
