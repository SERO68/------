// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:image_picker/image_picker.dart';
import '../../Database/database.dart';
import '../../provider/model.dart';
import 'goalsscreen.dart';

class AddGoal extends StatefulWidget {
  final Goal? goal;

  const AddGoal({super.key, this.goal});

  @override
  _AddGoalState createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {
  
  bool _isArabic(String text) {
    return text.isNotEmpty && RegExp(r'^[\u0621-\u064A]').hasMatch(text[0]);
  }
void _showAddItemDialog(String title, Function(String, String) onAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddItemDialog(title: title, onAdd: onAdd);
    },
  );
}


void _showEditItemDialog(String title, Map<String, String> item, Function(String, String) onEdit) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EditItemDialog(title: title, item: item, onEdit: onEdit);
    },
  );
}



  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _dueDate;
  String _description = '';
  final List<Map<String, String>> _milestones = [];
  final List<Map<String, String>> _tasks = [];
  File? _image;



  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _title = widget.goal!.name;
      _dueDate = widget.goal!.dueDate;
      _description = widget.goal!.description;

      if (widget.goal!.imagePath != null) {
        _image = File(widget.goal!.imagePath!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgrounds/goals.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0x003d3f68).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [SizedBox(height: screenHeight * 0.05),
                            GestureDetector(
                              onTap: () => _showImageOptions(),
                              child: _image == null
                                  ? const Icon(
                                      Icons.photo_library,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        _image!,
                                        width: double.infinity,
                                        height: screenHeight * 0.3,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              initialValue: _title,
                              decoration: const InputDecoration(
                                hintText: 'Title',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24, 
                              ),
                              textDirection:
                                  _isArabic(_title) ? TextDirection.rtl : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _title = value;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.white),
                                    const SizedBox(width: 5),
                                    TextButton(
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2101),
                                        );

                                        if (pickedDate != null) {
                                          setState(() {
                                            _dueDate =
                                                intl.DateFormat('yyyy-MM-dd')
                                                    .format(pickedDate);
                                          });
                                        }
                                      },
                                      child: Text(
                                        _dueDate ?? 'No Due Date',
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Milestones',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                           Column(
  children: _milestones
      .map((milestone) => GestureDetector(
            onTap: () {
              _showEditItemDialog(
                  'Edit Milestone', milestone,
                  (description, dueDate) {
                setState(() {
                  milestone['description'] = description;
                  milestone['dueDate'] = dueDate;
                });
              });
            },
            child: Container(
              width: double.infinity, 
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.transparent, 
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
           
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: RegExp(r'[\u0600-\u06FF]')
                            .hasMatch(milestone['description']!)
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: Text(
                      milestone['description']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold), 
                    ),
                  ),
                  Align(
                    alignment: RegExp(r'[\u0600-\u06FF]')
                            .hasMatch(milestone['description']!)
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: Text(
                      milestone['dueDate']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ))
      .toList(),
),

                            const SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                _showAddItemDialog('Add Milestone',
                                    (description, dueDate) {
                                  setState(() {
                                    _milestones.add({
                                      'description': description,
                                      'dueDate': dueDate
                                    });
                                  });
                                });
                              },
                              child: const Text('Add Milestone +'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tasks',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: _tasks
                                  .map((task) => Dismissible(
                                        key: Key(task['description']!),
                                        onDismissed: (direction) {
                                          setState(() {
                                            _tasks.remove(task);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Task deleted')));
                                        },
                                        background:
                                            Container(color: Colors.red),
                                        child: GestureDetector(
                                          onTap: () {
                                            _showEditItemDialog(
                                                'Edit Task', task,
                                                (description, dueDate) {
                                              setState(() {
                                                task['description'] =
                                                    description;
                                                task['dueDate'] = dueDate;
                                              });
                                            });
                                          },
                                          child: Container(
                                            width: double
                                                .infinity,
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: RegExp(
                                                              r'[\u0600-\u06FF]')
                                                          .hasMatch(task[
                                                              'description']!)
                                                      ? Alignment.topRight
                                                      : Alignment.topLeft,
                                                  child: Text(
                                                    task['description']!,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: RegExp(
                                                              r'[\u0600-\u06FF]')
                                                          .hasMatch(task[
                                                              'description']!)
                                                      ? Alignment.bottomLeft
                                                      : Alignment.bottomRight,
                                                  child: Text(
                                                    task['dueDate']!,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                _showAddItemDialog('Add Task',
                                    (description, dueDate) {
                                  setState(() {
                                    _tasks.add({
                                      'description': description,
                                      'dueDate': dueDate
                                    });
                                  });
                                });
                              },
                              child: const Text('Add Tasks +'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Describe your goal',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextFormField(
                                initialValue: _description,
                                decoration: const InputDecoration(
                                  hintText: 'Description ...',
                                  hintStyle: TextStyle(
                                      color:
                                          Color.fromARGB(255, 156, 156, 156)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                style: const TextStyle(color: Colors.white),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    _description = value;
                                  });
                                },
                                textAlign: RegExp(r'[\u0600-\u06FF]')
                                        .hasMatch(_description)
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color(0x003d3f68).withOpacity(1),
                                minimumSize: const Size(double.infinity, 60),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_dueDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please select a due date')),
                                    );
                                  } else {
                                    _saveGoal();
                                  }
                                }
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageOptions() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                try {
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                    Navigator.pop(context);
                  }
                } catch (e) {
                log(e.toString());
                }
              },
            ),
           
          ],
        );
      },
    );
  }


  void _saveGoal() async {
    final newGoal = Goal(
      name: _title,
      dueDate: _dueDate,
      tasksCompleted: 0,
      totalTasks: _tasks.length,
      milestonesCompleted: 0,
      totalMilestones: _milestones.length,
      description: _description,
      imagePath: _image?.path,
    );

    try {
      int goalId = await DatabaseHelper.insertGoal(newGoal);

      for (var task in _tasks) {
        final newTask = Tasks(
          goalId: goalId,
          description: task['description']!,
          dueDate: task['dueDate']!,
        );
        await DatabaseHelper.insertTask(newTask);
      }

      for (var milestone in _milestones) {
        final newMilestone = Milestone(
          goalId: goalId,
          description: milestone['description']!,
          dueDate: milestone['dueDate']!,
        );
        await DatabaseHelper.insertMilestone(newMilestone);
      }

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $error')),
      );
    }
  }
  
}

class AddItemDialog extends StatefulWidget {
  final String title;
  final Function(String, String) onAdd;

  const AddItemDialog({super.key, required this.title, required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
   bool _isArabic(String text) {
    return text.isNotEmpty && RegExp(r'^[\u0621-\u064A]').hasMatch(text[0]);
  }
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _dueDate;
  bool _isDescriptionArabic = false;

  void _checkDescriptionLanguage() {
    final isArabic = _isArabic(descriptionController.text);
    if (_isDescriptionArabic != isArabic) {
      setState(() {
        _isDescriptionArabic = isArabic;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    descriptionController.addListener(_checkDescriptionLanguage);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0x003d3f68).withOpacity(1),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              textDirection: _isDescriptionArabic ? TextDirection.rtl : TextDirection.ltr,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Description';
                }
                return null;
              },
            ),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    _dueDate = intl.DateFormat('yyyy-MM-dd').format(pickedDate);
                    dueDateController.text = _dueDate!;
                    setState(() {}); 
                  }
                },
                child: Text(
                  _dueDate ?? 'Select Due Date',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add', style: TextStyle(color: Colors.white)),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (_dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                      'Please select a due date',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                final description = descriptionController.text;
                final dueDate = dueDateController.text;
                widget.onAdd(description, dueDate);
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final String title;
  final Map<String, String> item;
  final Function(String, String) onEdit;

  const EditItemDialog({super.key, required this.title, required this.item, required this.onEdit});

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController descriptionController;
  late TextEditingController dueDateController;
  String? _dueDate;
  bool _isDescriptionArabic = false;

   bool _isArabic(String text) {
    return text.isNotEmpty && RegExp(r'^[\u0621-\u064A]').hasMatch(text[0]);
  }
  void _checkDescriptionLanguage() {
    _isDescriptionArabic = _isArabic(descriptionController.text);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.item['description']);
    dueDateController = TextEditingController(text: widget.item['dueDate']);
    _dueDate = widget.item['dueDate'];
    _isDescriptionArabic = _isArabic(descriptionController.text);
    descriptionController.addListener(_checkDescriptionLanguage);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0x003d3f68).withOpacity(1),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              textDirection: _isDescriptionArabic ? TextDirection.rtl : TextDirection.ltr,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Description';
                }
                return null;
              },
            ),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    _dueDate = intl.DateFormat('yyyy-MM-dd').format(pickedDate);
                    dueDateController.text = _dueDate!;
                    setState(() {}); 
                  }
                },
                child: Text(
                  _dueDate ?? 'Select Due Date',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save', style: TextStyle(color: Colors.white)),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (_dueDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                      'Please select a due date',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                final description = descriptionController.text;
                final dueDate = dueDateController.text;
                widget.onEdit(description, dueDate);
                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const GoalsScreen()));
              }
            }
          },
        ),
      ],
    );
  }
}
