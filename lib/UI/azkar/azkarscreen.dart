import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../provider/model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';
import 'showazkar.dart';


class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {

  @override
  void initState() {
    super.initState(); 
    _showDialogOnce();

  }

 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time3')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text('دي الاذكار اللي حتقريها كل يوم عشان تديني الاجر قصدي عشان تاخدي الاجر والثواب طبعا'),
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
      prefs.setBool('is_first_time3', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      body:  Consumer<Model>(
        builder: (context, model, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: model.currentBackgrounds['azkar']!['type'] == 'asset'
                    ? AssetImage(model.currentBackgrounds['azkar']!['path']!)
                        as ImageProvider
                    : FileImage(
                        File(model.currentBackgrounds['azkar']!['path']!)),
                fit: BoxFit.cover,
              ),
            ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              height: constraints.maxHeight,
              child: Padding(
                    padding: EdgeInsets.only(
                      left: constraints.maxWidth * 0.05,
                      right: constraints.maxWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        const Header(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: model.azkar.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  model.index = index;
                                  model.pointerazkar = 0;
                                  model.zero();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Showazkar()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  width: constraints.maxWidth * 0.9,
                                  height: constraints.maxHeight * 0.1,
                                  decoration: BoxDecoration(
                                    color: const Color(0x003d3f68)
                                        .withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        right: constraints.maxWidth * 0.06,
                                        top: constraints.maxHeight * 0.025,
                                        child: Text(
                                          model.azkar[index].title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'deco',
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: constraints.maxWidth * 0.06,
                                        top: constraints.maxHeight * 0.03,
                                        child: model.azkar[index].icon,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
               
              ),
            );
          }),
        ),
      );
  },),);
  }
}
