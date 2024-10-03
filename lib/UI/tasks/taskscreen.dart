// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../Database/database.dart';
import '../../provider/model.dart';
import '../../provider/taskprov.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';
import 'tasskdetails.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}
class _TasksScreenState extends State<TasksScreen> {

  
  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
        _showDialogOnce();

  }



 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time11')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text(' قسم المهام المؤجلة واللي مش بتخلص يا سكر اهو حتضيفي مهمة من زرار الزيادة من تحت متنسيش وتقدري تحذفي التاسك عن طريق السحب لليمين او الشمال '),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      prefs.setBool('is_first_time11', false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return const AddTaskForm();
            },
          );
        },
        foregroundColor: const Color.fromARGB(255, 5, 49, 85),
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      body:Consumer<Model>(
        builder: (context, model, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: model.currentBackgrounds['tasks']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['tasks']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['tasks']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                height: constraints.maxHeight,
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                 

                    return Padding(
                      padding: EdgeInsets.only(
                        left: constraints.maxWidth * 0.05,
                        right: constraints.maxWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          const Header(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Tasks',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto'),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.02,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: taskProvider.tasks.length,
                              itemBuilder: (context, index) {
                                Tasks task = taskProvider.tasks[index];
                                bool isArabic = RegExp(r'^[\u0621-\u064A]')
                                    .hasMatch(task.description);

                                return SizedBox(
                                  height: constraints.maxHeight * 0.18,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskDetailScreen(task: task),
                                        ),
                                      );
                                    },
                                    child: Dismissible(
                                      key: Key(task.id.toString()),
                                      onDismissed: (direction) {
                                        taskProvider.deleteTask(task.id!);
                                      },
                                      child: GlassContainer(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        width: constraints.maxWidth * 0.9,
                                        height: constraints.maxHeight * 0.18,
                                        borderRadius: BorderRadius.circular(15),
                                        color: const Color.fromARGB(
                                            255, 5, 49, 85),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromARGB(255, 89, 59, 210)
                                                .withOpacity(0.1),
                                            const Color.fromARGB(255, 69, 15, 176)
                                                .withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderGradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(0.5),
                                          ],
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Positioned(
                                              left: isArabic
                                                  ? null
                                                  : constraints.maxWidth * 0.05,
                                              right: isArabic
                                                  ? constraints.maxWidth * 0.05
                                                  : null,
                                              top: constraints.maxHeight * 0.04,
                                              child: Column(
                                                crossAxisAlignment: isArabic
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    task.description,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                    textDirection: isArabic
                                                        ? TextDirection.rtl
                                                        : TextDirection.ltr,
                                                  ),
                                                  Text(
                                                    task.dueDate,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                    textDirection: isArabic
                                                        ? TextDirection.rtl
                                                        : TextDirection.ltr,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              left: isArabic
                                                  ? constraints.maxWidth * 0.05
                                                  : null,
                                              right: isArabic
                                                  ? null
                                                  : constraints.maxWidth * 0.05,
                                              top: constraints.maxHeight *
                                                  0.045,
                                              child: IconButton(
                                                onPressed: () {
                                                  task.isCompleted =
                                                      !task.isCompleted;
                                                  taskProvider.updateTask(task);
                                                },
                                                icon: task.isCompleted
                                                    ? const FaIcon(
                                                        FontAwesomeIcons
                                                            .circleCheck,
                                                        color: Color.fromRGBO(
                                                            195, 204, 247, 0.73),
                                                        size: 30,
                                                      )
                                                    : const FaIcon(
                                                        FontAwesomeIcons.circle,
                                                        color: Color.fromRGBO(
                                                            195, 204, 247, 0.73),
                                                        size: 30,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
  },),);
  }
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}
class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _dueTimeController = TextEditingController();
  int? _selectedGoalId;
  bool _isTaskNameArabic = false;

  @override
  void initState() {
    super.initState();

    
    _taskNameController.addListener(_checkTaskNameLanguage);
  }

  @override
  void dispose() {
    _taskNameController.removeListener(_checkTaskNameLanguage);
    _taskNameController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
    super.dispose();
  }

  void _checkTaskNameLanguage() {
    setState(() {
      _isTaskNameArabic = _isArabic(_taskNameController.text);
    });
  }

  bool _isArabic(String text) {
    return text.isNotEmpty && RegExp(r'^[\u0621-\u064A]').hasMatch(text[0]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C54),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Task',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              TextFormField(
                controller: _taskNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                textDirection:
                    _isTaskNameArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dueDateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dueDateController.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      textDirection: _isTaskNameArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a due date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dueTimeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Due time',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _dueTimeController.text =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      textDirection: _isTaskNameArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a due time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Goal>>(
                future: DatabaseHelper.getGoals(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButtonFormField<int>(
                      dropdownColor: const Color.fromARGB(255, 58, 58, 58),
                      value: _selectedGoalId,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Goal',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2C2C54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'None',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ...snapshot.data!.map((goal) {
                          return DropdownMenuItem<int>(
                            value: goal.id,
                            child: Text(goal.name,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGoalId = value;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      iconSize: 24,
                      isExpanded: true,
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load goals');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String dueDateTime =
                        "${_dueDateController.text} ${_dueTimeController.text}";
                    DatabaseHelper.insertTask(Tasks(
                      goalId: _selectedGoalId ?? 0,
                      description: _taskNameController.text,
                      dueDate: dueDateTime,
                      isCompleted: false,
                    ));

                   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TasksScreen()));
                                
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                  backgroundColor: const Color(0xFF4D4D7E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
