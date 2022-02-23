import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class DatabaseHandler {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'flutter_health.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE indicators(id INTEGER PRIMARY KEY, time TEXT, water INTEGER, walk INTEGER, food INTEGER, is_exercise_enabled BOOLEAN, exercise_start_time TEXT, exercise_type TEXT, exercise_duration TEXT, photo TEXT, name TEXT, gender TEXT, growth REAL, weight REAL, birthday TEXT, level TEXT)"
        );
        await database.execute(
          "CREATE TABLE exercises(id INTEGER PRIMARY KEY, is_activated BOOLEAN, name TEXT, logo INTEGER, is_favorite BOOLEAN)"
        );
        await database.execute(
          "CREATE TABLE controllers(id INTEGER PRIMARY KEY, is_activated BOOLEAN, name TEXT)"
        );
        await database.execute(
          "CREATE TABLE measures(id INTEGER PRIMARY KEY, name TEXT, value TEXT)"
        );
        await database.execute(
          "CREATE TABLE body_records(id INTEGER PRIMARY KEY, marks TEXT, musculature INTEGER, fat INTEGER, weight REAL, date TEXT)"
        );
        // await database.execute(
        //   "DROP DATABASE flutter_health.db"
        // );
        // await database.execute(
        //   "DROP DATABASE flutter_health"
        // );
      },
      onOpen: (database) async {

        await database.execute(
            "CREATE TABLE sleep_records(id INTEGER PRIMARY KEY, hours TEXT, minutes TEXT, date TEXT)"
        );
        await database.execute(
            "CREATE TABLE food_records(id INTEGER PRIMARY KEY, type TEXT)"
        );
        await database.execute(
            "CREATE TABLE exercise_records(id INTEGER PRIMARY KEY, type TEXT, datetime TEXT, duration TEXT)"
        );
        await database.execute(
            "CREATE TABLE food_items(id INTEGER PRIMARY KEY, name TEXT, callories INTEGER, total_carbs INTEGER, total_fats INTEGER, protein INTEGER, saturated_fats INTEGER, trans_fats INTEGER, cholesterol INTEGER, sodium INTEGER, potassium INTEGER, cellulose INTEGER, sugar INTEGER, a INTEGER, c INTEGER, calcium INTEGER, iron INTEGER, portions REAL, type TEXT)"
        );
        await database.execute(
            "CREATE TABLE awards(id INTEGER PRIMARY KEY, name TEXT, description TEXT, type TEXT)"
        );
        // await database.execute(
        //   "DELETE DATABASE flutter_health"
        // );
        // await database.execute(
        //   "DELETE DATABASE flutter_health"
        // );
        Future<List<Indicators>> rawIndicators = retrieveIndicators();
        rawIndicators.then((value) async {
          print('Длина: $value.length');
          bool isPreInstall = value.length <= 0;
          if (isPreInstall) {
            addNewIndicators('', 0, 0, 0, 0, '', '', '', '', '', '', 0.0, 0.0, '', '');

            await database.execute("DELETE FROM \"exercises\";");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (1, \"Ходьба\", 0, 1);");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (1, \"Бег\", 0, 1);");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (1, \"Велоспорт\", 0, 1);");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (0, \"Поход\", 0, 0);");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (0, \"Плавание\", 0, 0);");
            await database.execute("INSERT INTO \"exercises\"(is_activated, name, logo, is_favorite) VALUES (0, \"Йога\", 0, 0);");

          }
        });
      },
      version: 1,
    );
  }

  Future<List<Indicators>> retrieveIndicators() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('indicators');
    var returnedIndicators = queryResult.map((e) => Indicators.fromMap(e)).toList();
    return returnedIndicators;
  }

  Future<int> insertIndicators(List<Indicators> indicators) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var indicatorsItem in indicators){
      result = await db.insert('indicators', indicatorsItem.toMap());
    }
    return result;
  }

  Future<int> addNewIndicators(String time, int water, int walk, int food, int is_exercise_enabled, String exercise_start_time, String exercise_type, String exercise_duration, String photo, String name, String gender, double growth, double weight, String birthday, String level) async {
    Indicators firstIndicators = Indicators(
        time: time,
        water: water,
        walk: walk,
        food: food,
        is_exercise_enabled: is_exercise_enabled,
        exercise_start_time: exercise_start_time,
        exercise_type: exercise_type,
        exercise_duration: exercise_duration,
        photo: photo,
        name: name,
        gender: gender,
        growth: growth,
        weight: weight,
        birthday: birthday,
        level: level
    );
    List<Indicators> listOfIndicators = [firstIndicators];
    return await insertIndicators(listOfIndicators);
  }

  Future<void> updateWaterIndicators(int water) async {
    final db = await initializeDB();
    Map<String, dynamic> values = Map<String, dynamic>();
    values = {
      'water': water
    };
    int indicatorsId = 1;
    await db.update(
      'indicators',
      values,
      where: 'id = ?',
      whereArgs: [indicatorsId]
    );
  }

  Future<int> insertBodyRecords(List<BodyRecord> bodyRecords) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var bodyRecord in bodyRecords){
      result = await db.insert('body_records', bodyRecord.toMap());
    }
    return result;
  }

  Future<int> addNewBodyRecord(String marks, int musculature, int fat, double weight, String date) async {
    BodyRecord firstBodyRecord = BodyRecord(
        marks: marks,
        musculature: musculature,
        fat: fat,
        weight: weight,
        date: date
    );
    List<BodyRecord> listOfBodyRecords = [firstBodyRecord];
    return await insertBodyRecords(listOfBodyRecords);
  }

  Future<List<BodyRecord>> retrieveBodyRecords() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('body_records');
    var returnedBodyRecords = queryResult.map((e) => BodyRecord.fromMap(e)).toList();
    return returnedBodyRecords;
  }

  Future<int> insertSleepRecords(List<SleepRecord> sleepRecords) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var sleepRecord in sleepRecords){
      result = await db.insert('sleep_records', sleepRecord.toMap());
    }
    return result;
  }

  Future<int> addNewSleepRecord(String hours, String minutes, String date) async {
    SleepRecord firstSleepRecord = SleepRecord(
        hours: hours,
        minutes: minutes,
        date: date
    );
    List<SleepRecord> listOfSleepRecords = [firstSleepRecord];
    return await insertSleepRecords(listOfSleepRecords);
  }

  Future<List<SleepRecord>> retrieveSleepRecords() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('sleep_records');
    var returnedSleepRecords = queryResult.map((e) => SleepRecord.fromMap(e)).toList();
    return returnedSleepRecords;
  }

  Future<int> insertFoodRecords(List<FoodRecord> foodRecords) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var foodRecord in foodRecords){
      result = await db.insert('food_records', foodRecord.toMap());
    }
    return result;
  }

  Future<int> addNewFoodRecord(String type) async {
    FoodRecord firstFoodRecord = FoodRecord(
        type: type
    );
    List<FoodRecord> listOfFoodRecords = [firstFoodRecord];
    return await insertFoodRecords(listOfFoodRecords);
  }

  Future<List<FoodRecord>> retrieveFoodRecords() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('food_records');
    var returnedFoodRecords = queryResult.map((e) => FoodRecord.fromMap(e)).toList();
    return returnedFoodRecords;
  }

  Future<int> insertExerciseRecords(List<ExerciseRecord> exerciseRecords) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var exerciseRecord in exerciseRecords){
      result = await db.insert('exercise_records', exerciseRecord.toMap());
    }
    return result;
  }

  Future<int> addNewExerciseRecord(String type, String datetime, String duration) async {
    ExerciseRecord firstExerciseRecord = ExerciseRecord(
      type: type,
      datetime: datetime,
      duration: duration
    );
    List<ExerciseRecord> listOfExerciseRecords = [firstExerciseRecord];
    return await insertExerciseRecords(listOfExerciseRecords);
  }

  Future<List<ExerciseRecord>> retrieveExerciseRecords() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('exercise_records');
    var returnedExerciseRecords = queryResult.map((e) => ExerciseRecord.fromMap(e)).toList();
    return returnedExerciseRecords;
  }

  Future<int> insertFoodItems(List<FoodItem> foodItems) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var foodItem in foodItems){
      result = await db.insert('food_items', foodItem.toMap());
    }
    return result;
  }

  Future<int> addNewFoodItem(String name, int callories, int total_carbs, int total_fats, int protein, int saturated_fats, int trans_fats, int cholesterol, int sodium, int potassium, int cellulose, int sugar, int a, int c, int calcium, int iron, double portions, String type) async {
    FoodItem firstFoodItem = FoodItem(
        name: name,
        callories: callories,
        total_carbs: total_carbs,
        total_fats: total_fats,
        protein: protein,
        saturated_fats: saturated_fats,
        trans_fats: trans_fats,
        cholesterol: cholesterol,
        sodium: sodium,
        potassium: potassium,
        cellulose: cellulose,
        sugar: sugar,
        a: a,
        c: c,
        calcium: calcium,
        iron: iron,
        portions: portions,
        type: type
    );
    List<FoodItem> listOfFoodItems = [firstFoodItem];
    return await insertFoodItems(listOfFoodItems);
  }

  Future<List<FoodItem>> retrieveFoodItems() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('food_items');
    var returnedFoodItems = queryResult.map((e) => FoodItem.fromMap(e)).toList();
    return returnedFoodItems;
  }

  Future<List<Exercise>> retrieveExercises() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('exercises');
    var returnedExercices = queryResult.map((e) => Exercise.fromMap(e)).toList();
    return returnedExercices;
  }

  Future<void> updateIsActivated(int id, int isActivated) async {
    final db = await initializeDB();
    Map<String, dynamic> values = Map<String, dynamic>();
    values = {
      'is_activated': isActivated
    };
    int indicatorsId = 1;
    await db.update(
      'exercises',
      values,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> updateIsFavorite(int id, bool isFavorite) async {
    final db = await initializeDB();
    Map<String, dynamic> values = Map<String, dynamic>();
    int rawIsFavorite = isFavorite ? 1 : 0;
    values = {
      'is_favorite': rawIsFavorite
    };
    await db.update(
      'exercises',
      values,
      where: 'id = ?',
      whereArgs: [id]
    );
  }

}