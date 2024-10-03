import 'package:flutter/material.dart';

import '../homescreen.dart';



class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _inController;
  late AnimationController _outController;
  late Animation<double> _heartAnimation;

Future<void> loadImages(BuildContext context) async {
  List<String> imagePaths = [
    'images/texture2.png',
    'images/dashboard/dashboard1.png',
    'images/dashboard/tasks.png',
    'images/dashboard/goals.png',
    'images/dashboard/diary.png',
    'images/dashboard/selfdashboard.png',
    
  ];

  for (var path in imagePaths) {
    await precacheImage(AssetImage(path), context);
  }
}

  @override
  void initState() {
    super.initState();

    _inController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _outController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(CurvedAnimation(
      parent: _outController,
      curve: Curves.easeInOut,
    ));

    _inController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      }
    });
  }

  @override
  void dispose() {
    _inController.dispose();
    _outController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      loadImages(context).then((_) async {
          await Future.delayed(const Duration(seconds:1), (){   Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()));}
      );
   
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _heartAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: HeartPainter(_heartAnimation.value),
                child: Center(
                  child: ScaleTransition(
                    scale: _inController,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 50.0,
                    ),
                  ),
                ),
              );
            },
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 200.0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final double progress;

  HeartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    final width = size.width;
    final height = size.height;
    final scale = progress * 1.5; 

    heartPath.moveTo(width / 2, height / 4 * scale);
    heartPath.cubicTo(
      width / 4 * scale, height / 12 * scale,
      0, height / 2 * scale,
      width / 2, height * scale,
    );
    heartPath.cubicTo(
      width, height / 2 * scale,
      width / 4 * 3 * scale, height / 12 * scale,
      width / 2, height / 4 * scale,
    );

    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}