import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category; // general, urgent, event, maintenance
  final String postedBy;
  final String postedByName;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime? expiresAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.postedBy,
    required this.postedByName,
    required this.isUrgent,
    required this.createdAt,
    this.expiresAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'general',
      postedBy: map['postedBy'] ?? '',
      postedByName: map['postedByName'] ?? '',
      isUrgent: map['isUrgent'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'postedBy': postedBy,
      'postedByName': postedByName,
      'isUrgent': isUrgent,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
}
