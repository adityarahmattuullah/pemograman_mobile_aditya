import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/preference_helper.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeChange;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onThemeChange,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String filter = 'Semua';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    notes = await PreferenceHelper.loadNotes();
    setState(() {});
  }

  IconData iconCategory(String cat) {
    switch (cat) {
      case 'Kuliah':
        return Icons.school;
      case 'Organisasi':
        return Icons.groups;
      case 'Pribadi':
        return Icons.person;
      default:
        return Icons.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'Semua'
        ? notes
        : notes.where((e) => e.category == filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          Switch(
            value: widget.isDark,
            onChanged: widget.onThemeChange,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField(
              value: filter,
              decoration: const InputDecoration(
                labelText: 'Filter Kategori',
                border: OutlineInputBorder(),
              ),
              items: ['Semua', 'Kuliah', 'Organisasi', 'Pribadi', 'Lain-lain']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => filter = v!),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final note = filtered[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(iconCategory(note.category)),
                      title: Text(note.title),
                      subtitle: Text(
                        '${note.category} • ${note.createdAt.toLocal().toString().split(" ")[0]}',
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                AddEditPage(note: note),
                            transitionsBuilder:
                                (_, animation, __, child) =>
                                    SlideTransition(
                              position: Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                        );
                        if (result != null) {
                          notes[i] = result;
                          PreferenceHelper.saveNotes(notes);
                          setState(() {});
                        }
                      },
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          notes.removeAt(i);
                          PreferenceHelper.saveNotes(notes);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: TweenAnimationBuilder(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditPage()),
            );
            if (result != null) {
              notes.add(result);
              PreferenceHelper.saveNotes(notes);
              setState(() {});
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
