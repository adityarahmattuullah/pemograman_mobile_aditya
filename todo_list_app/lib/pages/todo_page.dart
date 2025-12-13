import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/todo_item.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoStorage storage = TodoStorage();
  List<Todo> todos = [];
  String filter = 'Semua';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    todos = await storage.loadTodos();
    setState(() {});
  }

  void saveData() => storage.saveTodos(todos);

  List<Todo> get filteredTodos {
    if (filter == 'Selesai') {
      return todos.where((t) => t.isDone).toList();
    } else if (filter == 'Belum') {
      return todos.where((t) => !t.isDone).toList();
    }
    return todos;
  }

  void showTodoDialog({int? index}) {
    final controller = TextEditingController(
      text: index != null ? todos[index].title : '',
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              index == null ? 'Tambah Todo' : 'Edit Todo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Apa yang akan kamu lakukan?',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  if (index == null) {
                    todos.add(Todo(title: controller.text));
                  } else {
                    todos[index].title = controller.text;
                  }
                  saveData();
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTodoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Todo'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Todo List',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // FILTER CHIP
              Wrap(
                spacing: 8,
                children: ['Semua', 'Selesai', 'Belum'].map((e) {
                  return ChoiceChip(
                    label: Text(e),
                    selected: filter == e,
                    onSelected: (_) {
                      filter = e;
                      setState(() {});
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: filteredTodos.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada todo ✨',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTodos.length,
                        itemBuilder: (context, i) {
                          final todo = filteredTodos[i];
                          final index = todos.indexOf(todo);

                          return TodoItem(
                            todo: todo,
                            onToggle: () {
                              todo.isDone = !todo.isDone;
                              saveData();
                              setState(() {});
                            },
                            onDelete: () {
                              todos.removeAt(index);
                              saveData();
                              setState(() {});
                            },
                            onEdit: () => showTodoDialog(index: index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
