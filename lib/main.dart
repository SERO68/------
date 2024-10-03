import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam/provider/model.dart';
import 'UI/onboard/loadscreen.dart';
import 'provider/taskprov.dart';
import 'UI/onboard/welcomescreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
        create: (context) => Model(),
        child: ChangeNotifierProvider(
          create: (context) => TaskProvider(),
          child: const MyApp(),
        )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فهماكي',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 5, 3, 49)),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: Provider.of<Model>(context, listen: false).checkFirstSeen(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return const WelcomeScreen();
            } else {
              return const LoadingScreen();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
