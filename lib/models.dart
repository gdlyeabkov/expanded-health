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