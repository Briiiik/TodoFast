import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  runApp(const TodoFastApp());
}

class TodoFastApp extends StatelessWidget {
  const TodoFastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoFast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final List<String> _tasks = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _addTask() {
    final String task = _taskController.text.trim();
    if (task.isEmpty) {
      _showEmptyTaskWarning();
      return;
    }

    setState(() {
      _tasks.insert(0, task); // Ajoute en haut de la liste
      _listKey.currentState?.insertItem(0);
      _taskController.clear();
    });
  }

  void _showEmptyTaskWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez entrer une tâche valide'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _removeTask(int index) async {
    final String removedTask = _tasks.removeAt(index);
    
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedTask, animation),
      duration: const Duration(milliseconds: 300),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tâche supprimée: "$removedTask"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
              _listKey.currentState?.insertItem(index);
            });
          },
        ),
      ),
    );
  }

  Widget _buildRemovedItem(String task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: Colors.red.withOpacity(0.1),
        child: ListTile(
          title: Text(
            task,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, int index, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            _tasks[index],
            style: const TextStyle(fontSize: 16),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeTask(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoFast', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          hintText: 'Ajouter une nouvelle tâche...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                      iconSize: 32,
                      onPressed: _addTask,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _tasks.length,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index, animation) {
                return _buildTaskItem(context, index, animation);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de TodoFast'),
        content: const Text(
          'Une application simple et élégante pour gérer vos tâches quotidiennes.\n\n'
          '• Ajoutez des tâches\n'
          '• Supprimez avec un effet sympa\n'
          '• Design moderne Material 3',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}