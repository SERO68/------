import 'package:flutter/material.dart';
import 'package:sam/provider/model.dart';

import '../Database/database.dart';



class TaskProvider with ChangeNotifier {
  List<Tasks> _tasks = [];

  List<Tasks> get tasks => _tasks;

  Future<void> fetchTasks() async {
    _tasks = await DatabaseHelper.getAllTasks();
    notifyListeners();
  }

  void updateTask(Tasks task) {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      DatabaseHelper.updateTask(task);
      notifyListeners();
    }
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    DatabaseHelper.deleteTask(id);
    notifyListeners();
  }
}
