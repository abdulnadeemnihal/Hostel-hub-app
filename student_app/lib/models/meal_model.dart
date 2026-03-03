import 'package:cloud_firestore/cloud_firestore.dart';

class MealMenu {
  final String id;
  final String day;
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;
  final DateTime weekStartDate;
  final DateTime createdAt;

  MealMenu({
    required this.id,
    required this.day,
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
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
