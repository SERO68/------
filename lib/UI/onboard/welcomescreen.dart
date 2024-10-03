import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/model.dart';
import 'loadscreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/backgrounds/FirstBackground.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                height: constraints.maxHeight,
                child: Consumer<Model>(builder: (context, model, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.1),
                            Column(
                              children: [
                                const Text(
                                  'Welcome',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 60,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'To Start Press Below',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: constraints.maxHeight * 1 / 35,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                          constraints.maxWidth * 0.75,
                                          constraints.maxHeight * 0.08),
                                      maximumSize: Size(
                                          constraints.maxWidth * 0.75,
                                          constraints.maxHeight * 0.08),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  onPressed: () {
                                    
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoadingScreen()),
                                              (route)=>false,
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lets Start Journey',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 20,
                                            color: Color.fromARGB(
                                                255, 33, 8, 104)),
                                      ),
                                      Icon(Icons.arrow_circle_right_outlined),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                      ),
                    ],
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
