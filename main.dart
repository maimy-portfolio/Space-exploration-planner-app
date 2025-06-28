import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(ProviderScope(child: MyApp()));

// Model
class Task {
  final int id;
  final String label;
  final bool isDone;

  Task({required this.id, required this.label, this.isDone = false});

  Task copyWith({bool? isDone}) {
    return Task(
      id: id,
      label: label,
      isDone: isDone ?? this.isDone,
    );
  }
}

// StateNotifier
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier({required List<Task> tasks}) : super(tasks);

  void toggleTask(int id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isDone: !task.isDone)
        else
          task,
    ];
  }

  void addTask(String label) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      label: label,
    );
    state = [...state, newTask];
  }

  void deleteTask(int id) {
    state = state.where((task) => task.id != id).toList();
  }

  int get completedCount => state.where((task) => task.isDone).length;
}

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(tasks: [

  ]);
});

// UI
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exploration!',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(tasksProvider.notifier).addTask(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Space Exploration Planner!"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Progress(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8,),
                ElevatedButton(
                    onPressed: _addTask,
                    child: Text('Add'),
                )
              ],
            ),
          ),
          Expanded(child: TaskList()),
        ],
      ),
    );
  }
}



class Progress extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final completed = tasks.where((t) => t.isDone).length;
    final total = tasks.length;
    return Column(
      children: [
        Text("You are this far away from exploring whole universe: "),
        LinearProgressIndicator(
          value: total > 0 ? completed / total : 0.0,
        ),
      ],
    );
  }
}

class TaskList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);
    return Column(
      children: tasks.map((task) => TaskItem(task: task)).toList(),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
          value: task.isDone,
          onChanged: (_) {
            ref.read(tasksProvider.notifier).toggleTask(task.id);
          },
        ),
        Expanded(
          child: Text(
            task.label,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
              color: task.isDone ? Colors.grey : Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            ref.read(tasksProvider.notifier).deleteTask(task.id);
          },
        ),
      ],
    );
  }
}