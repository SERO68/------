import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io'; 
import 'package:glass_kit/glass_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/database.dart';
import '../../provider/model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';
import 'addgoal.dart';
import 'goaldetails.dart';



class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {

    @override
  void initState() {
    super.initState(); 
    _showDialogOnce();

  }

 _showDialogOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time1')?? true;

    if ( isFirstTime == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial'),
          content: const Text('هنا بقي المكان اللي حتكتبي في اهدافك الخيالية عشان تحاولي تحققيقها'),
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
      prefs.setBool('is_first_time1', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawerapp(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoal()),
          );
        },
        foregroundColor: const Color.fromARGB(255, 5, 49, 85),
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    height: constraints.maxHeight,
                    child: Consumer<Model>(
                      builder: (context, model, child) {
                        return Padding(
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
                                    'Goals',
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
                                child: FutureBuilder<List<Goal>>(
                                  future: DatabaseHelper.getGoals(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          Goal goal = snapshot.data![index];
                                          return SizedBox(
                                            height: constraints.maxHeight * 0.2,
                                            width: constraints.maxWidth * 0.9,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GoalDetailScreen(
                                                            goal: goal),
                                                  ),
                                                );
                                              },
                                              child: Dismissible(
                                                key: Key(goal.id.toString()),
                                                onDismissed: (direction) {
                                                  DatabaseHelper.deleteGoal(
                                                      goal.id!);
                                                },
                                                child: GoalTile(
                                                  imageUrl:
                                                      goal.imagePath ?? '',
                                                  dueDate: goal.dueDate ??
                                                      'No due date',
                                                  name: goal.name,
                                                  tasksCompleted:
                                                      goal.tasksCompleted,
                                                  totalTasks: goal.totalTasks,
                                                  milestonesCompleted:
                                                      goal.milestonesCompleted,
                                                  totalMilestones:
                                                      goal.totalMilestones,
                                                ),
                                              ),
                                            ),
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
                        );
                      },
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

class GoalTile extends StatelessWidget {
  final String imageUrl;
  final String dueDate;
  final String name;
  final int tasksCompleted;
  final int totalTasks;
  final int milestonesCompleted;
  final int totalMilestones;

  const GoalTile({
    required this.imageUrl,
    required this.dueDate,
    required this.name,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.milestonesCompleted,
    required this.totalMilestones,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GlassContainer(
      blur: 20,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(15),
      color: const Color.fromARGB(255, 5, 49, 85),
      gradient: LinearGradient(
        colors: [
          const Color.fromARGB(255, 89, 59, 210).withOpacity(0.1),
          const Color.fromARGB(255, 69, 15, 176).withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.5),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty && File(imageUrl).existsSync()
                ? Image.file(
                    File(imageUrl),
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.14,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'images/default.jpg',
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.14,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueDate,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 218, 218, 218),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$tasksCompleted/$totalTasks Tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$milestonesCompleted/$totalMilestones Milestones',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
