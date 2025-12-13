import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class PreferenceHelper {
  static const noteKey = 'notes';
  static const themeKey = 'darkMode';

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      noteKey,
      notes.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(noteKey);
    if (data == null) return [];
    return data.map((e) => Note.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(themeKey, isDark);
  }

  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? false;
  }
}
