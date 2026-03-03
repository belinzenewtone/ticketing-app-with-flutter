import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tasks_provider.dart';
import '../../models/task.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(tasksProvider),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final pending =
              tasks.where((t) => !t.completed).toList();
          final done = tasks.where((t) => t.completed).toList();

          return tasks.isEmpty
              ? const Center(
                  child: Text('No tasks yet',
                      style: TextStyle(color: Color(0xFF94A3B8))))
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(tasksProvider),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (pending.isNotEmpty) ...[
                        const Text('Pending',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        ...pending
                            .map((t) => _TaskTile(task: t, ref: ref)),
                        const SizedBox(height: 16),
                      ],
                      if (done.isNotEmpty) ...[
                        const Text('Completed',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8))),
                        const SizedBox(height: 8),
                        ...done.map((t) => _TaskTile(task: t, ref: ref)),
                      ],
                    ],
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddTask(context, ref),
      ),
    );
  }

  void _showAddTask(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Task title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = ctrl.text.trim();
              if (title.isEmpty) return;
              await TaskService.createTask(title);
              ref.invalidate(tasksProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final WidgetRef ref;

  const _TaskTile({required this.task, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          activeColor: const Color(0xFF059669),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
          onChanged: (v) async {
            await TaskService.updateTask(task.id, {'completed': v});
            ref.invalidate(tasksProvider);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            color: task.completed
                ? const Color(0xFF94A3B8)
                : const Color(0xFF1E293B),
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline,
              size: 18, color: Color(0xFFCBD5E1)),
          onPressed: () async {
            await TaskService.deleteTask(task.id);
            ref.invalidate(tasksProvider);
          },
        ),
      ),
    );
  }
}
