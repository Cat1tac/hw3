import 'package:cloud_firestore/cloud_firestore.dart';
import '/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  /// Add a new task to Firestore
  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    await _tasksCollection.add({
      'title': trimmed,
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Returns a continuous stream of the full task list, ordered
  /// by creation date (newest first).
  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Task.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            }).toList());
  }

  /// Toggle the completion status of a task.
  Future<void> toggleTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  /// Replace the full task document with updated data.
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  /// Permanently delete a task from Firestore.
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
}
