import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';


class Showazkar extends StatelessWidget {
  const Showazkar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      body: Consumer<Model>(
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
                  child:  Padding(
                        padding: EdgeInsets.only(
                          left: constraints.maxWidth * 0.05,
                          right: constraints.maxWidth * 0.05,
                        ),
                        child: Column(
                          children: [
                            const Header(),
                            // ---------------
                            SizedBox(height: constraints.maxHeight * 0.005),
                            GestureDetector(
                              onTap: () {
                                model.incrementCounter();
                              },
                              child: Container(
                                height: constraints.maxHeight * 0.8,
                                width: constraints.maxWidth * 0.9,
                                padding: EdgeInsets.all(
                                  constraints.maxHeight * 0.035,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0x003d3f68).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          model.azkar[model.index]
                                              .data[model.pointerazkar]['text'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontFamily: 'deco',
                                              wordSpacing: 1,
                                              height: 2,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        model.incrementCounter();
                                      },
                                      child: Text(
                                        model.counterazkar[model.pointerazkar]
                                            .toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight *
                                            0.02), 
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (model.pointerazkar > 0) {
                                              model.minpointer();
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: constraints.maxWidth * 0.1,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            model.refreshazkar();
                                          },
                                          icon: const Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: constraints.maxWidth * 0.1,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (model.pointerazkar <
                                                model.azkar[model.index].data
                                                        .length -
                                                    1) {
                                              model.plspointer();
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
