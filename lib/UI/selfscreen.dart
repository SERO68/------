import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/model.dart';
import '../widgets/drawer.dart';
import '../widgets/header.dart';



class Selfscreen extends StatefulWidget {
  const Selfscreen({super.key});

  @override
  State<Selfscreen> createState() => _SelfscreenState();
}

class _SelfscreenState extends State<Selfscreen> {

  

  Map<String, Map<String, bool>> prayerStates = {
    'الصبح': {'fard': false, 'sunnah': false},
    'الظهر': {'fard': false, 'sunnah': false},
    'العصر': {'fard': false, 'sunnah': false},
    'المغرب': {'fard': false, 'sunnah': false},
    'العشاء': {'fard': false, 'sunnah': false},
    'حفظ': {'fard': false},
    'ورد اليومى': {'fard': false},
    'اذكار الصباح': {'fard': false},
    'اذكار المساء': {'fard': false},
     'الضحى': {'fard': false,},
    'قيام الليل': {'fard': false, },
  };

bool once = true;

  @override
  void initState() {
    super.initState(); 
    _showDialogOnce();
      once = true; 

    _loadPrayerStates();
  }

 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time8')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text('هنا المكان اللي حتجلدي فيه ذاتك كل يوم قسم المحاسبة النفسية بس لو عملتي كل المهام حتلاقي تشجيع يارب يعجبك بس'),
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
      prefs.setBool('is_first_time8', false);
    }
  }

  Future<void> _loadPrayerStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('lastDate');
    String currentDate = DateTime.now().toString().split(' ')[0];

    if (lastDate != currentDate) {
      prefs.setString('lastDate', currentDate);
      _resetPrayerStates();
    } else {
      prayerStates.forEach((key, value) {
        prayerStates[key]!['fard'] = prefs.getBool('$key-fard') ?? false;
        if (value.containsKey('sunnah')) {
          prayerStates[key]!['sunnah'] = prefs.getBool('$key-sunnah') ?? false;
        }
      });
    }

    setState(() {});
    _checkAllIconsTrue(); 
  }

Future<void> _savePrayerState(String prayer, String type, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('$prayer-$type', value);
}

  void _resetPrayerStates() {
    setState(() {
      prayerStates.forEach((key, value) {
        prayerStates[key]!['fard'] = false;
        if (value.containsKey('sunnah')) {
          prayerStates[key]!['sunnah'] = false;
        }
      });
    });
  }

  void _checkAllIconsTrue() {once=true;
  bool allTrue = prayerStates.values.every((states) => states['fard']! && (states['sunnah'] == null || states['sunnah']!));
  if (allTrue && once ) {
    _showDialog();
    once = false; 
  }
  }


  void _showDialog() {
    final player = AudioPlayer();
    player.play(AssetSource('زغروته ليبيه.mp3'));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/fox-fluffy-cheeks-a31kf3jg4uc0pwm6.gif'),
              const Text(
                'عاش يااشطر كتكوتة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      body: Consumer<Model>(
      builder: (context, model, child) {
      return DecoratedBox(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: model.currentBackgrounds['self']!['type'] == 'asset'
          ? AssetImage(model.currentBackgrounds['self']!['path']!) as ImageProvider
          : FileImage(File(model.currentBackgrounds['self']!['path']!)),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        width: constraints.maxWidth * 0.9,
                        height: constraints.maxHeight * 0.8,
                        decoration: BoxDecoration(
                          color: const Color(0x003d3f68).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.03),
                              buildCategory1('الصلاة', [
                                buildRow1('الصبح'),
                                buildRow1('الظهر'),
                                buildRow1('العصر'),
                                buildRow1('المغرب'),
                                buildRow1('العشاء'),
                             
                              ]),
                              buildCategory2('القران الكريم', [
                                buildRow2('حفظ'),
                                buildRow2('ورد اليومى'),
                              ]),
                              buildCategory2('عمر جنتك', [
                                buildRow2('اذكار الصباح'),
                                buildRow2('اذكار المساء'),
                                   buildRow2('الضحى'),
                                buildRow2('قيام الليل'),
                              ]),
                            ],
                          ),
                        ),
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

Widget buildCategory1(String title, List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        return Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: width * 0.05), 
                const Text(
                  'الفرض',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: width * 0.1), 
                const Text(
                  'السنن',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: width * 0.04), 
              ],
            ),
            const SizedBox(height: 10),
            ...children,
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildCategory2(String title, List<Widget> children) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildRow1(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Image.asset(
                  prayerStates[text]!['fard']! ? 'images/green.png' : 'images/red.png',
                  width: 50),
              iconSize: 20,
              onPressed: () {
                setState(() {
                  prayerStates[text]!['fard'] = !prayerStates[text]!['fard']!;
                  _savePrayerState(text, 'fard', prayerStates[text]!['fard']!);
                      _checkAllIconsTrue();
                });
              },
            ),
            IconButton(
              icon: Image.asset(
                  prayerStates[text]!['sunnah']! ? 'images/green.png' : 'images/red.png',
                  width: 50),
              iconSize: 20,
              onPressed: () {
                setState(() {
                  prayerStates[text]!['sunnah'] = !prayerStates[text]!['sunnah']!;
                  _savePrayerState(text, 'sunnah', prayerStates[text]!['sunnah']!);
                  _checkAllIconsTrue();
                });
              },
            ),
          ],
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget buildRow2(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Image.asset(
                  prayerStates[text]!['fard']! ? 'images/green.png' : 'images/red.png',
                  width: 50),
              iconSize: 20,
              onPressed: () {
                setState(() {
                  prayerStates[text]!['fard'] = !prayerStates[text]!['fard']!;
                  _savePrayerState(text, 'fard', prayerStates[text]!['fard']!);
                      _checkAllIconsTrue();
                });
              },
            ),
          ],
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }
}
