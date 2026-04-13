import 'package:flutter/material.dart';
import 'task.dart';
import 'task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/subtask_panel.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  String? _expandedTaskId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // Add task with validation 

  void _addTask() {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      // Show validation feedback — don't write empty docs to Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Task name cannot be empty',
            style: TextStyle(fontSize: 13),
          ),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _taskService.addTask(title);
    _taskController.clear();
    _inputFocus.requestFocus();
  }

  // Delete with confirmation 

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete task?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently remove "${task.title}".',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              _taskService.deleteTask(task.id);
              if (_expandedTaskId == task.id) {
                setState(() => _expandedTaskId = null);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  // Filter tasks by search query 

  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks
        .where((t) => t.title.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // Build progress bar data 

  Widget _buildProgressBar(List<Task> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final pct = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 3,
                backgroundColor: AppTheme.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.purple),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purple.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text('Tasks'),
          ],
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskService.streamTasks(),
        builder: (context, snapshot) {
            //connecting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.purple,
                strokeWidth: 2,
              ),
            );
          }

          // error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.danger, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final allTasks = snapshot.data ?? [];
          final filteredTasks = _filterTasks(allTasks);

          return Column(
            children: [
              // Progress bar
              if (allTasks.isNotEmpty) _buildProgressBar(allTasks),

              // Search bar 
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 10, right: 6),
                        child: Icon(Icons.search,
                            size: 16, color: AppTheme.textMuted),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 32, minHeight: 0),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  size: 14, color: AppTheme.textMuted),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),

              // Add task input 
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        focusNode: _inputFocus,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'What needs to be done?',
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: allTasks.isEmpty
                    ? _buildEmptyState()
                    : filteredTasks.isEmpty
                        ? _buildNoResults()
                        : _buildTaskList(filteredTasks),
              ),
            ],
          );
        },
      ),
    );
  }

  // Empty state (no tasks at all) 

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '—',
            style: TextStyle(
              fontSize: 32,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tasks yet',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type above to create one',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // No search results

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '·',
            style: TextStyle(
              fontSize: 32,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No matches',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try different keywords',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Task list builder 

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isExpanded = _expandedTaskId == task.id;

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              TaskTile(
                task: task,
                isExpanded: isExpanded,
                onToggle: () => _taskService.toggleTask(task),
                onDelete: () => _confirmDelete(task),
                onTap: () {
                  setState(() {
                    _expandedTaskId = isExpanded ? null : task.id;
                  });
                },
              ),
              // Subtask panel (visible when expanded)
              if (isExpanded)
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: AppTheme.purple.withOpacity(0.2),
                    ),
                  ),
                  child: SubtaskPanel(
                    task: task,
                    taskService: _taskService,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
