import 'package:flutter/material.dart';
import '../model/activity_model.dart';

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
