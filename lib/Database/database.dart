import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../provider/model.dart';

class DatabaseHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'diary.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE diary(id INTEGER PRIMARY KEY, title TEXT, subtitle TEXT, date TEXT, imagePath TEXT, fontFamily TEXT, fontColor INTEGER)",
        );
db.execute(
  "CREATE TABLE goals(id INTEGER PRIMARY KEY, name TEXT, dueDate TEXT, tasksCompleted INTEGER, totalTasks INTEGER, milestonesCompleted INTEGER, totalMilestones INTEGER, description TEXT, imagePath TEXT)",
);

        db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY, goalId INTEGER, description TEXT, dueDate TEXT, isCompleted INTEGER, FOREIGN KEY(goalId) REFERENCES goals(id) ON DELETE CASCADE)",
        );
        db.execute(
          "CREATE TABLE milestones(id INTEGER PRIMARY KEY, goalId INTEGER, description TEXT, dueDate TEXT, isCompleted INTEGER, FOREIGN KEY(goalId) REFERENCES goals(id) ON DELETE CASCADE)",
        );
          db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, key TEXT, value TEXT)",
        );
      },
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
        
          await db.execute("DROP TABLE IF EXISTS diary");
          await db.execute("DROP TABLE IF EXISTS goals");
          await db.execute("DROP TABLE IF EXISTS tasks");
          await db.execute("DROP TABLE IF EXISTS milestones");
          await db.execute("DROP TABLE IF EXISTS settings");


        
        
          await db.execute(
            "CREATE TABLE diary(id INTEGER PRIMARY KEY, title TEXT, subtitle TEXT, date TEXT, imagePath TEXT, fontFamily TEXT, fontColor INTEGER)",
          );
          await db.execute(
  "CREATE TABLE goals(id INTEGER PRIMARY KEY, name TEXT, dueDate TEXT, tasksCompleted INTEGER, totalTasks INTEGER, milestonesCompleted INTEGER, totalMilestones INTEGER, description TEXT, imagePath TEXT)",
);

          await db.execute(
            "CREATE TABLE tasks(id INTEGER PRIMARY KEY, goalId INTEGER, description TEXT, dueDate TEXT, isCompleted INTEGER, FOREIGN KEY(goalId) REFERENCES goals(id) ON DELETE CASCADE)",
          );
          await db.execute(
            "CREATE TABLE milestones(id INTEGER PRIMARY KEY, goalId INTEGER, description TEXT, dueDate TEXT, isCompleted INTEGER, FOREIGN KEY(goalId) REFERENCES goals(id) ON DELETE CASCADE)",
          );
          await  db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, key TEXT, value TEXT)",
        );
        }
      },
    );
  }

static Future<void> saveSetting(String key, String value) async {
  final db = await database();
  await db.rawInsert(
    'INSERT OR REPLACE INTO settings(key, value) VALUES(?, ?)',
    [key, value],
  );
}
  static Future<Map<String, String>> getSettings() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query('settings');

    return { for (var item in maps) item['key'] as String : item['value'] as String };
  }

  static Future<List<Diary>> getDiaries() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query('diary');

    return List.generate(maps.length, (i) {
      return Diary.fromMap(maps[i]);
    });
  }

  static Future<void> deleteDiary(int id) async {
    final db = await database();
    await db.delete(
      'diary',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertDiary(Diary diary) async {
    final db = await DatabaseHelper.database();
    await db.insert(
      'diary',
      diary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateDiary(Diary diary) async {
    final db = await DatabaseHelper.database();
    await db.update(
      'diary',
      diary.toMap(),
      where: "id = ?",
      whereArgs: [diary.id],
    );
  }

  static Future<int> insertGoal(Goal goal) async {
    final db = await DatabaseHelper.database();
    return await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Goal>> getGoals() async {
    final db = await DatabaseHelper.database();
    final List<Map<String, dynamic>> goalMap = await db.query('goals');
    return List.generate(goalMap.length, (i) {
      return Goal.fromMap(goalMap[i]);
    });
  }

  static Future<void> deleteGoal(int id) async {
    final db = await DatabaseHelper.database();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }


    static Future<void> updateGoal(Goal goal) async {
    final db = await DatabaseHelper.database();
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

static Future<void> updateTask(Tasks task) async {
  final db = await DatabaseHelper.database();
  await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
  int completedTasks = (await db.query(
    'tasks',
    where: 'goalId = ? AND isCompleted = 1',
    whereArgs: [task.goalId],
  )).length;

  await db.update(
    'goals',
    {'tasksCompleted': completedTasks},
    where: 'id = ?',
    whereArgs: [task.goalId],
  );
}

static Future<void> updateMilestone(Milestone milestone) async {
  final db = await DatabaseHelper.database();
  await db.update(
    'milestones',
    milestone.toMap(),
    where: 'id = ?',
    whereArgs: [milestone.id],
  );
  int completedMilestones = (await db.query(
    'milestones',
    where: 'goalId = ? AND isCompleted = 1',
    whereArgs: [milestone.goalId],
  )).length;


  await db.update(
    'goals',
    {'milestonesCompleted': completedMilestones},
    where: 'id = ?',
    whereArgs: [milestone.goalId],
  );
}


  static Future<void> insertTask(Tasks task) async {
  final db = await DatabaseHelper.database();
  await db.insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  
  int totalTasks = (await db.query(
    'tasks',
    where: 'goalId = ?',
    whereArgs: [task.goalId],
  )).length;

  await db.update(
    'goals',
    {'totalTasks': totalTasks},
    where: 'id = ?',
    whereArgs: [task.goalId],
  );
}



  static Future<List<Tasks>> getTasks(int goalId) async {
    final db = await DatabaseHelper.database();
    final List<Map<String, dynamic>> taskMap =
        await db.query('tasks', where: 'goalId = ?', whereArgs: [goalId]);
    return List.generate(taskMap.length, (i) {
      return Tasks.fromMap(taskMap[i]);
    });
  }

  static Future<void> deleteTask(int id) async {
    final db = await DatabaseHelper.database();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }


  static Future<List<Tasks>> getAllTasks() async {
    final db = await DatabaseHelper.database();
    final List<Map<String, dynamic>> taskMap = await db.query('tasks');
    return List.generate(taskMap.length, (i) {
      return Tasks.fromMap(taskMap[i]);
    });
  }

  
  static Future<void> insertMilestone(Milestone milestone) async {
    final db = await DatabaseHelper.database();
    await db.insert(
      'milestones',
      milestone.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Milestone>> getMilestones(int goalId) async {
    final db = await DatabaseHelper.database();
    final List<Map<String, dynamic>> milestoneMap =
        await db.query('milestones', where: 'goalId = ?', whereArgs: [goalId]);
    return List.generate(milestoneMap.length, (i) {
      return Milestone.fromMap(milestoneMap[i]);
    });
  }

  static Future<void> deleteMilestone(int id) async {
    final db = await DatabaseHelper.database();
    await db.delete('milestones', where: 'id = ?', whereArgs: [id]);
  }

  
}
