import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/activity_model.dart';
import 'activity_detail_page.dart';
import 'add_activity_page.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("activities");

    if (data != null) {
      List list = jsonDecode(data);
      setState(() {
        activities = list.map((e) => Activity.fromMap(e)).toList();
      });
    }
  }

  Future<void> saveActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(activities.map((e) => e.toMap()).toList());
    prefs.setString("activities", jsonData);
  }

  /// ICON KATEGORI
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "ibadah":
        return Icons.self_improvement;
      case "belajar":
        return Icons.menu_book;
      case "hiburan":
        return Icons.movie;
      case "olahraga":
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  /// ADD Activity
  Future<void> addNewActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityPage()),
    );

    if (result is Activity) {
      setState(() => activities.add(result));
      saveActivities();

      // 🔥 NOTIFIKASI BERHASIL DISIMPAN
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Aktivitas berhasil disimpan!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Activity Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ActivitySearchDelegate(activities),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNewActivity,
        child: const Icon(Icons.add),
      ),

      body: activities.isEmpty
          ? const Center(
              child: Text(
                "Belum ada aktivitas",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final a = activities[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),

                    // 🔥 ICON KATEGORI
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getCategoryIcon(a.category),
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),

                    title: Text(
                      a.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text("Durasi: ${a.duration} Jam"),
                        Text("Status: ${a.isCompleted ? "Selesai" : "Belum"}"),
                        Text("Kategori: ${a.category}"),
                      ],
                    ),

                    trailing: const Icon(Icons.chevron_right),

                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityDetailPage(
                            activity: a,
                            index: index,
                          ),
                        ),
                      );

                      // 🔥 HAPUS
                      if (result == "delete") {
                        setState(() => activities.removeAt(index));
                        saveActivities();

                        // NOTIF HAPUS
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Aktivitas dihapus"),
                            backgroundColor: const Color.fromARGB(255, 216, 124, 117),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }

                      // 🔥 EDIT (UPDATE)
                      else if (result is Activity) {
                        setState(() => activities[index] = result);
                        saveActivities();

                        // NOTIF EDIT
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Aktivitas berhasil diperbarui!"),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// ===================
/// SEARCH DELEGATE
/// ===================
class ActivitySearchDelegate extends SearchDelegate {
  final List<Activity> allActivities;

  ActivitySearchDelegate(this.allActivities);

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => buildList();

  @override
  Widget buildSuggestions(BuildContext context) => buildList();

  Widget buildList() {
    final results = allActivities
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text("Tidak ditemukan"));
    }

    return ListView(
      children: results
          .map(
            (a) => ListTile(
              title: Text(a.name),
              subtitle: Text(
                "Durasi: ${a.duration} Jam — Status: ${a.isCompleted ? "Selesai" : "Belum"}",
              ),
            ),
          )
          .toList(),
    );
  }
}
