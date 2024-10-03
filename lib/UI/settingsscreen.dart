import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../provider/model.dart';
import '../widgets/drawer.dart';
import '../widgets/header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  
  @override
  void initState() {
    super.initState(); 
    _showDialogOnce();

  }

 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time9')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text('هوب دي الاعدادات حتقدري تغيري فيها كام حاجة مع اني لا انصح مطلقا بتغير اي حاجة الا انك تقفلي كلمة السر عشان مزعج انك تكتبيها في كل مرة'),
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
      prefs.setBool('is_first_time9', false);
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
                image: model.currentBackgrounds['settings']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['settings']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['settings']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                height: constraints.maxHeight,
                child:  Padding(
                    padding: EdgeInsets.only(
                      left: constraints.maxWidth * 0.05,
                      right: constraints.maxWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        const Header(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: constraints.maxWidth * 0.02),
                                const Text(
                                  'Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SettingsButton(
                              text: 'Change Name',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChangeNameScreen()),
                                );
                              },
                            ),
                            SettingsButton(
                              text: 'Change profile pic',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangeProfilePicScreen()),
                                );
                              },
                            ),
                            SettingsButton(
                              text: 'Change a Background',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangeBackgroundScreen()),
                                );
                              },
                            ),
           
                           
                          ],
                        ),
                      ],
                    ),
                  
                ),
              );
            },
          ),
        ),
      );
  },),);
  }
}

class SettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SettingsButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x003d3f68).withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeProfilePicScreen extends StatefulWidget {
  const ChangeProfilePicScreen({super.key});

  @override
  _ChangeProfilePicScreenState createState() => _ChangeProfilePicScreenState();
}

class _ChangeProfilePicScreenState extends State<ChangeProfilePicScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Provider.of<Model>(context, listen: false)
          .changeImage(FileImage(_image!));
    }
  }

  void _saveAndReturn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 64, 66, 138) ,
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Add your profile picture',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.01,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            backgroundColor: const WidgetStatePropertyAll(
                               Color.fromARGB(255, 64, 66, 138) ),
                            fixedSize: WidgetStatePropertyAll(Size(
                                constraints.maxWidth * 0.8,
                                constraints.maxHeight * 0.064))),
                        onPressed: _saveAndReturn,
                        child: const Text(
                          'Save and Return',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChangeNameScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  ChangeNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Change Name', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 64, 66, 138) ,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter new name',
                labelStyle: const TextStyle(color:Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<Model>(context, listen: false)
                    .changeName(_nameController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 64, 66, 138) ,
                     foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeBackgroundScreen extends StatefulWidget {
  const ChangeBackgroundScreen({super.key});

  @override
  _ChangeBackgroundScreenState createState() => _ChangeBackgroundScreenState();
}

class _ChangeBackgroundScreenState extends State<ChangeBackgroundScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(String screen) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      Provider.of<Model>(context, listen: false)
          .changeBackground(screen, pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Background'),
      ),
      body: Consumer<Model>(
        builder: (context, model, child) {
          return ListView.builder(
            itemCount: model.currentBackgrounds.length,
            itemBuilder: (context, index) {
              String screen = model.currentBackgrounds.keys.elementAt(index);
              String imagePath = model.currentBackgrounds[screen]!['path']!;
              String imageType = model.currentBackgrounds[screen]!['type']!;
              bool isFile = imageType == 'file';

              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    isFile
                        ? Image.file(File(imagePath))
                        : Image.asset(imagePath),
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        screen,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _pickImage(screen),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
