// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


import 'dart:io';

import '../../Database/database.dart';
import '../../provider/model.dart';
import '../../widgets/drawer.dart';
import 'diaryscreen.dart';

class AddDiary extends StatefulWidget {
  final Diary? diary;

  const AddDiary({super.key, this.diary});

  @override
  _AddDiaryState createState() => _AddDiaryState();
}

class _AddDiaryState extends State<AddDiary> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  String? imagePath;
  String fontFamily = 'Roboto';
  Color fontColor = Colors.black;

  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isArabicTitle = true; 
  bool _isArabicSubtitle =
      true; 
  final Color _fontColor = Colors.white;
  final String _fontFamily = 'Roboto'; 

  @override
  void initState() {
    super.initState();

    if (widget.diary != null) {
      titleController.text = widget.diary!.title;
      subtitleController.text = widget.diary!.subtitle;
      imagePath = widget.diary!.imagePath;
      fontFamily = widget.diary!.fontFamily;
      fontColor = Color(widget.diary!.fontColor);
      _selectedImage = imagePath != null ? File(imagePath!) : null;
      _isArabicTitle = isArabicText(widget.diary!.title);
      _isArabicSubtitle = isArabicText(widget.diary!.subtitle);
    }
  }

  bool isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      body: Consumer<Model>(
        builder: (context, model, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: model.currentBackgrounds['diary']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['diary']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['diary']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.02),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildForm(context, constraints),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        _buildBottomButtons(context, constraints),
                        SizedBox(height: constraints.maxHeight * 0.02),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildForm(BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxHeight * 0.025),
      decoration: BoxDecoration(
        color: const Color(0x003d3f68).withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_selectedImage != null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    _selectedImage!,
                    height: constraints.maxHeight * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            TextFormField(
              textDirection:
                  _isArabicTitle ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                color: _fontColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: _fontFamily,
              ),
              controller: titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'العنوان',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: _fontFamily,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  _isArabicTitle = isArabicText(text);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(
              height: constraints.maxHeight * 0.02,
            ),
            SizedBox(
              height: constraints.maxHeight * 0.64,
              child: TextFormField(
                textDirection:
                    _isArabicSubtitle ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  color: _fontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  fontFamily: _fontFamily,
                ),
                controller: subtitleController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'مفكرتي العزيزة ...',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 179, 179, 179),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: _fontFamily,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _isArabicSubtitle = isArabicText(text);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x003d3f68).withOpacity(0.7),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            focusColor: Colors.white,
            splashColor: Colors.white,
            color: Colors.white,
            splashRadius: 20,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Diary newDiary = Diary(
                  id: widget.diary?.id,
                  title: titleController.text,
                  subtitle: subtitleController.text,
                  date: widget.diary?.date ?? DateTime.now().toString(),
                  imagePath: _selectedImage?.path, 
                  fontFamily: _fontFamily, 
                  fontColor: _fontColor.value, 
                );

                if (widget.diary == null) {
                  await DatabaseHelper.insertDiary(newDiary);
                } else {
                  await DatabaseHelper.updateDiary(newDiary);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryScreen()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      content: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.redAccent,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Image(
                            image: AssetImage('images/foxno.png'),
                            width: 200,
                            height: 200,
                          ),
                          Text(
                            'You left something empty!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DiaryScreen()));
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.white,
          ),
          IconButton(
            focusColor: Colors.white,
            splashColor: Colors.white,
            color: Colors.white,
            splashRadius: 20,
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickImage,
          ),
        ],
      ),
    );
  }
}
