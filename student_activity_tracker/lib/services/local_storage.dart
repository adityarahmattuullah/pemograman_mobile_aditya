import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/activity_model.dart';

class LocalStorage {
  static const String key = "activities";

  // SIMPAN LIST
  static Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();

    final data = activities.map((a) => a.toMap()).toList();

    prefs.setString(key, jsonEncode(data));
  }

  // AMBIL LIST
  static Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    return decoded.map((map) => Activity.fromMap(map)).toList();
  }
}
