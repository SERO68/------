// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unnecessary_null_comparison

import 'package:flutter/material.dart';
import '../../Database/database.dart';
import '../../provider/model.dart';

class TaskDetailScreen extends StatefulWidget {
  final Tasks task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  int? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDueDate = widget.task.dueDate != null ? DateTime.parse(widget.task.dueDate) : null;
    _selectedGoalId = widget.task.goalId;
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    widget.task.description = _descriptionController.text;
    widget.task.dueDate = _selectedDueDate?.toIso8601String() ?? '';
    widget.task.goalId = _selectedGoalId ?? widget.task.goalId;
    await DatabaseHelper.updateTask(widget.task);
    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    await DatabaseHelper.deleteTask(widget.task.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(  backgroundColor: const Color(0xFF1A1A2E),iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Task Details',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickDueDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Due date',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedDueDate != null
                        ? "${_selectedDueDate!.toLocal()}".split(' ')[0]
                        : 'No due date',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Goal>>(
              future: DatabaseHelper.getGoals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Failed to load goals', style: TextStyle(color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  _selectedGoalId = null;
                  return DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1A1A2E),
                    value: _selectedGoalId,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Goal',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('None', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoalId = value;
                      });
                    },
                  );
                } else {
                  return DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1A1A2E),
                    value: _selectedGoalId,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Goal',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('None', style: TextStyle(color: Colors.white)),
                      ),
                      ...snapshot.data!.map((goal) {
                        return DropdownMenuItem<int>(
                          value: goal.id,
                          child: Text(goal.name, style: const TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoalId = value;
                      });
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Spacer(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _saveTask,
                  child: const Text('Done', style: TextStyle(color: Colors.green, fontSize: 20)),
                ),
                TextButton(
                  onPressed: _deleteTask,
                  child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
