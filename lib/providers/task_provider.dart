import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  late Box<Task> _tasksBox;

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    _tasksBox = await Hive.openBox<Task>('tasks');
    notifyListeners();
  }

  List<Task> get tasks => _tasksBox.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> addTask(Task task) async {
    await _tasksBox.add(task);
    notifyListeners();
  }

  Future<void> updateTask(int index, Task task) async {
    await _tasksBox.putAt(index, task);
    notifyListeners();
  }

  Future<void> deleteTask(int index) async {
    await _tasksBox.deleteAt(index);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(int index) async {
    final task = _tasksBox.getAt(index);
    if (task != null) {
      await _tasksBox.putAt(
        index,
        task.copyWith(isCompleted: !(task.isCompleted ?? false)),
      );
      notifyListeners();
    }
  }
}