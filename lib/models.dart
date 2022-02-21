class Indicators {
  final int? id;
  final String time;
  final int water;
  final int walk;
  final int food;
  final int is_exercise_enabled;
  final String exercise_start_time;
  final String exercise_type;
  final String exercise_duration;
  final String photo;
  final String name;
  final String gender;
  final double growth;
  final double weight;
  final String birthday;
  final String level;

  Indicators({
    this.id,
    required this.time,
    required this.water,
    required this.walk,
    required this.food,
    required this.is_exercise_enabled,
    required this.exercise_start_time,
    required this.exercise_type,
    required this.exercise_duration,
    required this.photo,
    required this.name,
    required this.gender,
    required this.growth,
    required this.weight,
    required this.birthday,
    required this.level
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'water': water,
      'walk': walk,
      'food': food,
      'is_exercise_enabled': is_exercise_enabled,
      'exercise_start_time': exercise_start_time,
      'exercise_type': exercise_type,
      'exercise_duration': exercise_duration,
      'photo': photo,
      'name': name,
      'gender': gender,
      'growth': growth,
      'weight': weight,
      'birthday': birthday,
      'level': level
    };
  }

  Indicators.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        time = res["time"],
        water = res["water"],
        walk = res["walk"],
        food = res["food"],
        is_exercise_enabled = res["is_exercise_enabled"],
        exercise_start_time = res["exercise_start_time"],
        exercise_type = res["exercise_type"],
        exercise_duration = res["exercise_duration"],
        photo = res["photo"],
        name = res["name"],
        gender = res["gender"],
        growth = res["growth"],
        weight = res["weight"],
        birthday = res["birthday"],
        level = res["level"];

}

class BodyRecord {
  final int? id;
  final String marks;
  final int musculature;
  final int fat;
  final double weight;
  final String date;

  BodyRecord({
    this.id,
    required this.marks,
    required this.musculature,
    required this.fat,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marks': marks,
      'musculature': musculature,
      'fat': fat,
      'weight': weight,
      'date': date,
    };
  }

  BodyRecord.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        marks = res["marks"],
        musculature = res["musculature"],
        fat = res["fat"],
        weight = res["weight"],
        date = res["date"];

}

class SleepRecord {
  final int? id;
  final String hours;
  final String minutes;
  final String date;

  SleepRecord({
    this.id,
    required this.hours,
    required this.minutes,
    required this.date
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hours': hours,
      'minutes': minutes,
      'date': date
    };
  }

  SleepRecord.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        hours = res["hours"],
        minutes = res["minutes"],
        date = res["date"];

}

class FoodRecord {
  final int? id;
  final String type;

  FoodRecord({
    this.id,
    required this.type
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type
    };
  }

  FoodRecord.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        type = res["type"];

}

class ExerciseRecord {

  final int? id;
  final String type;
  final String datetime;
  final String duration;

  ExerciseRecord({
    this.id,
    required this.type,
    required this.datetime,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'datetime': datetime,
      'duration': duration
    };
  }

  ExerciseRecord.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        type = res["type"],
        datetime = res["datetime"],
        duration = res["duration"];

}

class FoodItem {

  final int? id;
  final String name;
  final int callories;
  final int total_carbs;
  final int total_fats;
  final int protein;
  final int saturated_fats;
  final int trans_fats;
  final int cholesterol;
  final int sodium;
  final int potassium;
  final int cellulose;
  final int sugar;
  final int a;
  final int c;
  final int calcium;
  final int iron;
  final double portions;
  final String type;

  FoodItem({
    this.id,
    required this.name,
    required this.callories,
    required this.total_carbs,
    required this.total_fats,
    required this.protein,
    required this.saturated_fats,
    required this.trans_fats,
    required this.cholesterol,
    required this.sodium,
    required this.potassium,
    required this.cellulose,
    required this.sugar,
    required this.a,
    required this.c,
    required this.calcium,
    required this.iron,
    required this.portions,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'callories': callories,
      'total_carbs': total_carbs,
      'total_fats': total_fats,
      'protein': protein,
      'saturated_fats': saturated_fats,
      'trans_fats': trans_fats,
      'cholesterol': cholesterol,
      'sodium': sodium,
      'potassium': potassium,
      'cellulose': cellulose,
      'sugar': sugar,
      'a': a,
      'c': c,
      'calcium': calcium,
      'iron': iron,
      'portions': portions,
      'type': type,
    };
  }

  FoodItem.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        callories = res["callories"],
        total_carbs = res["total_carbs"],
        total_fats = res["total_fats"],
        protein = res["protein"],
        saturated_fats = res["saturated_fats"],
        trans_fats = res["trans_fats"],
        cholesterol = res["cholesterol"],
        sodium = res["sodium"],
        potassium = res["potassium"],
        cellulose = res["cellulose"],
        sugar = res["sugar"],
        a = res["a"],
        c = res["c"],
        calcium = res["calcium"],
        iron = res["iron"],
        portions = res["portions"],
        type = res["type"];

}

enum FoodType {
  none,
  breakfast,
  lanch,
  dinner,
  morningMeal,
  dayMeal,
  eveningMeal
}