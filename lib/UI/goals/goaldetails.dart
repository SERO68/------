// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/database.dart';
import '../../provider/model.dart';


class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  _GoalDetailScreenState createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String? _dueDate;
  late String _description;
  late List<Tasks> _tasks;
  late List<Milestone> _milestones;
  File? _image;
  bool _isAchieved = false;

  @override
  void initState() {
    super.initState();
    _title = widget.goal.name;
    _dueDate = widget.goal.dueDate;
    _description = widget.goal.description;
    _tasks = [];
    _milestones = [];
    _fetchData();
    _loadAchievementStatus();
    if (widget.goal.imagePath != null &&
        File(widget.goal.imagePath!).existsSync()) {
      _image = File(widget.goal.imagePath!);
    }
  }

  Future<void> _loadAchievementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAchieved = prefs.getBool('goal_${widget.goal.id}_achieved') ?? false;
    });
  }

  Future<void> _setAchievementStatus(bool achieved) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goal_${widget.goal.id}_achieved', achieved);
  }

  void _playAchievementSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('زغروته ليبيه.mp3'));
  }

  void _markAsAchieved() {
    _playAchievementSound();
    _setAchievementStatus(true);
    setState(() {
      _isAchieved = true;
    });
  }


  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<void> _fetchData() async {
    try {
      List<Tasks> tasks = await DatabaseHelper.getTasks(widget.goal.id!);
      List<Milestone> milestones =
          await DatabaseHelper.getMilestones(widget.goal.id!);
      setState(() {
        _tasks = tasks;
        _milestones = milestones;
      });
      log("Fetched tasks: $_tasks"); 
    } catch (e) {
      log("Error fetching data: $e");
      log("id is ${widget.goal.id}");
    }
  }
 @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Consumer<Model>(
        builder: (context, model, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: model.currentBackgrounds['goal']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['goal']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['goal']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0x003d3f68).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImageOptions(),
                        child: Container(
                          width: screenWidth,
                          height: screenHeight * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: _image != null
                                  ? FileImage(_image!)
                                  : const AssetImage(
                                          'images/default_goal_image.png')
                                      as ImageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          child: _image == null
                              ? const Icon(
                                  Icons.photo_library,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (_isAchieved)
                      const Center(
                        child: Text(
                          'This goal is achieved!!!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 7, 162, 43),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    TextFormField(
                      textDirection: _isArabic(_title) ? TextDirection.rtl : null,
                      initialValue: _title,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
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
                            const Icon(Icons.calendar_today, color: Colors.white),
                            const SizedBox(width: 5),
                            TextButton(
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _dueDate = intl.DateFormat('yyyy-MM-dd')
                                        .format(pickedDate);
                                  });
                                }
                              },
                              child: Text(
                                _dueDate ?? 'No Due Date',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _milestones.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_milestones[index].description),
                          onDismissed: (direction) {
                            setState(() {
                              DatabaseHelper.deleteMilestone(
                                  _milestones[index].id!);
                              _milestones.removeAt(index);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showEditItemDialogmilestone(
                                  'Edit milestone',
                                  _milestones[index], (description, dueDate) {
                                setState(() {
                                  _milestones[index].description = description;
                                  _milestones[index].dueDate = dueDate;
                                  DatabaseHelper.updateMilestone(
                                      _milestones[index]);
                                });
                              });
                            },
                            child: Card(
                              color: Colors.white.withOpacity(0.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.white)),
                              child: ListTile(
                                title: Text(
                                  _milestones[index].description,
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: _milestones[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  'Due Date: ${_milestones[index].dueDate}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: _milestones[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: Checkbox(
                                  side: const BorderSide(color: Colors.white),
                                  value: _milestones[index].isCompleted,
                                  onChanged: (bool? value) async {
                                    setState(() {
                                      _milestones[index].isCompleted =
                                          value ?? false;
                                    });
                                    await DatabaseHelper.updateMilestone(
                                        _milestones[index]);
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                            _milestones.add(Milestone(
                                goalId: widget.goal.id!,
                                description: description,
                                dueDate: dueDate));
                          });
                        });
                      },
                      child: const Text('Add Milestone +'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_tasks[index].description),
                          onDismissed: (direction) {
                            setState(() {
                              DatabaseHelper.deleteTask(_tasks[index].id!);
                              _tasks.removeAt(index);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showEditItemDialogtask(
                                  'Edit Task', _tasks[index], (description,
                                      dueDate) {
                                setState(() {
                                  _tasks[index].description = description;
                                  _tasks[index].dueDate = dueDate;
                                  DatabaseHelper.updateTask(_tasks[index]);
                                });
                              });
                            },
                            child: Card(
                              color: Colors.white.withOpacity(0.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.white)),
                              child: ListTile(
                                title: Text(
                                  _tasks[index].description,
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: _tasks[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  'Due Date: ${_tasks[index].dueDate}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: _tasks[index].isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: Checkbox(
                                  side: const BorderSide(color: Colors.white),
                                  value: _tasks[index].isCompleted,
                                  onChanged: (bool? value) async {
                                    setState(() {
                                      _tasks[index].isCompleted =
                                          value ?? false;
                                    });

                                    await DatabaseHelper.updateTask(
                                        _tasks[index]);
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        _showAddItemDialog('Add Task', (description, dueDate) {
                          setState(() {
                            _tasks.add(Tasks(
                                goalId: widget.goal.id!,
                                description: description,
                                dueDate: dueDate));
                          });
                        });
                      },
                      child: const Text('Add Tasks +'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Describe your goal',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        textAlign: RegExp(r'[\u0600-\u06FF]').hasMatch(_description)
                            ? TextAlign.right
                            : TextAlign.left,
                        initialValue: _description,
                        decoration: const InputDecoration(
                          hintText: 'Description ...',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 156, 156, 156)),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color(0x003d3f68).withOpacity(1),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_dueDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please select a due date')),
                                  );
                                } else {
                                  _saveGoal();
                                }
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color(0x003d3f68).withOpacity(1),
                            ),
                            onPressed: () {
                              _markAsAchieved();
                            },
                            child: const Text('Achieved'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },),  );
  }

  
  
  void _showAddItemDialog(String title, void Function(String, String) onAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddItemDialog(title: title, onAdd: onAdd);
    },
  );
}


  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemDialogtask(String title, Tasks task, Function(String, String) onEdit) {
     final descriptionController = TextEditingController(text: task.description);
    final dueDateController = TextEditingController(text: task.dueDate);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0x003d3f68).withOpacity(1),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  textDirection: _isArabic(_title) ? TextDirection.rtl : null,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
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
                        setState(() {
                          _dueDate =
                              intl.DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
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
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
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
                          )),
                    );
                  } else {    final description = descriptionController.text;
                final dueDate = dueDateController.text;
                    onEdit(description, dueDate);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialogmilestone(String title, Milestone milestone, Function(String, String) onEdit) {
  final descriptionController = TextEditingController(text: milestone.description);
  String? dialogDueDate = milestone.dueDate;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0x003d3f68).withOpacity(1),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                textDirection: _isArabic(descriptionController.text) ? TextDirection.rtl : null,
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
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
                      setState(() {
                        dialogDueDate = intl.DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  child: Text(
                    dialogDueDate ?? 'Select Due Date',
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
                if (dialogDueDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.white,
                        content: Text(
                          'Please select a due date',
                          style: TextStyle(color: Colors.red),
                        )),
                  );
                } else {
                  final description = descriptionController.text;
                  onEdit(description, dialogDueDate!);
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}

  
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGoal() async {
    try {
      if (_image != null) {
        widget.goal.imagePath = _image!.path;
      }
      widget.goal.name = _title;
      widget.goal.dueDate = _dueDate;
      widget.goal.description = _description;

  
      if (widget.goal.id != null) {
        await DatabaseHelper.updateGoal(widget.goal);
      } else {
        widget.goal.id = await DatabaseHelper.insertGoal(widget.goal);
      }

   
      if (widget.goal.id != null) {
        for (var task in _tasks) {
          task.goalId = widget.goal.id!;
          if (task.id != null) {
            await DatabaseHelper.updateTask(task);
          } else {
            await DatabaseHelper.insertTask(task);
          }
        }

        for (var milestone in _milestones) {
          milestone.goalId = widget.goal.id!;
          if (milestone.id != null) {
            await DatabaseHelper.updateMilestone(milestone);
          } else {
            await DatabaseHelper.insertMilestone(milestone);
          }
        }
      }

      Navigator.pop(context);
    } catch (e) {
      log("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e')),
      );
    }
  }

  
}

class AddItemDialog extends StatefulWidget {
  final String title;
  final void Function(String, String) onAdd;

  const AddItemDialog({super.key, required this.title, required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
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
                widget.onAdd(descriptionController.text, _dueDate!);
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }
}
