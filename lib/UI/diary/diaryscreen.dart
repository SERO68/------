import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/database.dart';
import '../../provider/model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';
import 'adddiary.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  
    @override
  void initState() {
    super.initState(); 
    _showDialogOnce();

  }

 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time2')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text('اما ده فاجمل حاجة صممتها ليكي ركن الفضفضة واليوميات '),
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
      prefs.setBool('is_first_time2', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiary()),
          );
        },
        foregroundColor: const Color.fromARGB(255, 5, 49, 85),
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Text(
          '+',
          style: TextStyle(fontSize: 30),
        ),
      ),
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Diary',
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
                                child: FutureBuilder<Map<String, List<Diary>>>(
                                  future: model.groupDiariesByMonth(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        itemCount: snapshot.data!.keys.length,
                                        itemBuilder: (context, index) {
                                          String month = snapshot.data!.keys
                                              .elementAt(index);
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                month,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color.fromARGB(
                                                      209, 255, 255, 255),
                                                ),
                                              ),
                                              ...snapshot.data![month]!.map(
                                                (diary) {
                                                  bool isEnglish = RegExp(
                                                          r'^[a-zA-Z0-9\s]+$')
                                                      .hasMatch(diary.title);
                                                  return SizedBox(
                                                    height:
                                                        constraints.maxHeight *
                                                            0.2,
                                                    width:
                                                        constraints.maxWidth *
                                                            0.9,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddDiary(
                                                                    diary:
                                                                        diary),
                                                          ),
                                                        );
                                                      },
                                                      child: Dismissible(
                                                        key: Key(diary.id
                                                            .toString()),
                                                        onDismissed:
                                                            (direction) {
                                                          DatabaseHelper
                                                              .deleteDiary(
                                                                  diary.id!);
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.4,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.2,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                    0x003d3f68)
                                                                .withOpacity(
                                                                    0.7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          child: Stack(
                                                            children: <Widget>[
                                                              Positioned(
                                                                right: isEnglish
                                                                    ? constraints
                                                                            .maxWidth *
                                                                        0.05
                                                                    : null,
                                                                left: isEnglish
                                                                    ? null
                                                                    : constraints
                                                                            .maxWidth *
                                                                        0.05,
                                                                top: constraints
                                                                        .maxHeight *
                                                                    0.03,
                                                                child: Text(
                                                                  model.getDayMonthName(
                                                                      diary
                                                                          .date),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            218,
                                                                            218,
                                                                            218),
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                left: isEnglish
                                                                    ? constraints
                                                                            .maxWidth *
                                                                        0.05
                                                                    : null,
                                                                right: isEnglish
                                                                    ? null
                                                                    : constraints
                                                                            .maxWidth *
                                                                        0.05,
                                                                top: constraints
                                                                        .maxHeight *
                                                                    0.06,
                                                                child: Column(
                                                                  crossAxisAlignment: isEnglish
                                                                      ? CrossAxisAlignment
                                                                          .start
                                                                      : CrossAxisAlignment
                                                                          .end,
                                                                  children: <Widget>[
                                                                    Text(
                                                                      diary
                                                                          .title,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            24,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontFamily:
                                                                            diary.fontFamily,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      diary
                                                                          .subtitle,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontFamily:
                                                                            diary.fontFamily,
                                                                      ),
                                                                    ),
                                                                  ],
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
                                            ],
                                          );
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text('An error occurred!');
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
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
        },
      ),
    );
  }
}
