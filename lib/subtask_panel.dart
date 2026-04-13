import 'package:flutter/material.dart';
import 'task.dart';
import 'task_service.dart';
import 'app_theme.dart';

/// Expandable panel that shows beneath a [TaskTile] when tapped.

class SubtaskPanel extends StatefulWidget {
  final Task task;
  final TaskService taskService;

  const SubtaskPanel({
    super.key,
    required this.task,
    required this.taskService,
  });

  @override
  State<SubtaskPanel> createState() => _SubtaskPanelState();
}

class _SubtaskPanelState extends State<SubtaskPanel> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  /// Add a new subtask entry to this task's subtask list.
  void _addSubtask() {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;

    final updatedSubtasks = [
      ...widget.task.subtasks,
      {'title': title, 'done': false},
    ];

    widget.taskService.updateTask(
      widget.task.copyWith(subtasks: updatedSubtasks),
    );
    _subtaskController.clear();
  }

  /// Toggle the done status of a subtask at [index].
  void _toggleSubtask(int index) {
    final updatedSubtasks =
        List<Map<String, dynamic>>.from(widget.task.subtasks);
    updatedSubtasks[index] = {
      ...updatedSubtasks[index],
      'done': !(updatedSubtasks[index]['done'] ?? false),
    };

    widget.taskService.updateTask(
      widget.task.copyWith(subtasks: updatedSubtasks),
    );
  }

  /// Remove a subtask at [index] from the list.
  void _removeSubtask(int index) {
    final updatedSubtasks =
        List<Map<String, dynamic>>.from(widget.task.subtasks);
    updatedSubtasks.removeAt(index);

    widget.taskService.updateTask(
      widget.task.copyWith(subtasks: updatedSubtasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(42, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Existing subtasks ──
          ...List.generate(widget.task.subtasks.length, (index) {
            final sub = widget.task.subtasks[index];
            final isDone = sub['done'] == true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  // Mini checkbox
                  GestureDetector(
                    onTap: () => _toggleSubtask(index),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDone ? AppTheme.purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isDone ? AppTheme.purple : AppTheme.textMuted,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              size: 9, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Subtask title
                  Expanded(
                    child: Text(
                      sub['title'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDone
                            ? AppTheme.textMuted
                            : AppTheme.textSecondary,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),

                  // Remove button
                  GestureDetector(
                    onTap: () => _removeSubtask(index),
                    child: Icon(
                      Icons.close,
                      size: 13,
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add subtask input
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _subtaskController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Add subtask…',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                            color: AppTheme.purple.withOpacity(0.4)),
                      ),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: _addSubtask,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
