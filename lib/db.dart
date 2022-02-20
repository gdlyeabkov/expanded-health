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
        addNewIndicators('', 0, 0, 0, 0, '', '', '', '', '', '', 0.0, 0.0, '', '');
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
          }
        });
        addNewIndicators('', 0, 0, 0, 0, '', '', '', '', '', '', 0.0, 0.0, '', '');
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

}