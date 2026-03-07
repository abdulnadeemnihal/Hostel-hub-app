import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String name;
  final int votes;

  PollOption({required this.name, required this.votes});

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      name: map['name'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'votes': votes};
  }
}

class MealPoll {
  final String id;
  final String title;
  final String mealType; // Breakfast, Lunch, Snack, Dinner
  final String targetDay; // Monday–Sunday
  final String foodType; // Vegetarian, Non-Vegetarian, Both
  final List<PollOption> options;
  final Map<String, int> voters; // studentId → optionIndex
  final String status; // active, closed
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? winner;
  final bool appliedToMenu;

  MealPoll({
    required this.id,
    required this.title,
    required this.mealType,
    required this.targetDay,
    required this.foodType,
    required this.options,
    required this.voters,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.winner,
    this.appliedToMenu = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == 'active' && !isExpired;
  int get totalVotes => options.fold<int>(0, (sum, o) => sum + o.votes);

  factory MealPoll.fromMap(Map<String, dynamic> map, String id) {
    final optionsList = (map['options'] as List<dynamic>?)
            ?.map((e) => PollOption.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final votersMap = (map['voters'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)) ??
        {};

    return MealPoll(
      id: id,
      title: map['title'] ?? '',
      mealType: map['mealType'] ?? '',
      targetDay: map['targetDay'] ?? '',
      foodType: map['foodType'] ?? 'Both',
      options: optionsList,
      voters: votersMap,
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      winner: map['winner'],
      appliedToMenu: map['appliedToMenu'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mealType': mealType,
      'targetDay': targetDay,
      'foodType': foodType,
      'options': options.map((o) => o.toMap()).toList(),
      'voters': voters,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'winner': winner,
      'appliedToMenu': appliedToMenu,
    };
  }
}
