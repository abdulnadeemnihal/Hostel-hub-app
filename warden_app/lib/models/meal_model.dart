import 'package:cloud_firestore/cloud_firestore.dart';

class MealMenu {
  final String id;
  final String day; // Monday, Tuesday, etc.
  final String foodType; // 'Vegetarian' or 'Non-Vegetarian'
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;
  final DateTime weekStartDate;
  final DateTime createdAt;

  MealMenu({
    required this.id,
    required this.day,
    required this.foodType,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
    required this.weekStartDate,
    required this.createdAt,
  });

  factory MealMenu.fromMap(Map<String, dynamic> map, String id) {
    return MealMenu(
      id: id,
      day: map['day'] ?? '',
      foodType: map['foodType'] ?? 'Vegetarian',
      breakfast: map['breakfast'] ?? '',
      lunch: map['lunch'] ?? '',
      snacks: map['snacks'] ?? '',
      dinner: map['dinner'] ?? '',
      weekStartDate: (map['weekStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'foodType': foodType,
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class MealPreference {
  final String id;
  final String studentId;
  final String mealType; // breakfast, lunch, snacks, dinner
  final String day;
  final bool optedIn;
  final int? rating; // 1-5
  final String? feedback;
  final DateTime date;

  MealPreference({
    required this.id,
    required this.studentId,
    required this.mealType,
    required this.day,
    required this.optedIn,
    this.rating,
    this.feedback,
    required this.date,
  });

  factory MealPreference.fromMap(Map<String, dynamic> map, String id) {
    return MealPreference(
      id: id,
      studentId: map['studentId'] ?? '',
      mealType: map['mealType'] ?? '',
      day: map['day'] ?? '',
      optedIn: map['optedIn'] ?? true,
      rating: map['rating'],
      feedback: map['feedback'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'mealType': mealType,
      'day': day,
      'optedIn': optedIn,
      'rating': rating,
      'feedback': feedback,
      'date': Timestamp.fromDate(date),
    };
  }
}
