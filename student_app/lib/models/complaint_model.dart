import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String category;
  final String title;
  final String description;
  final String status;
  final String? assignedTo;
  final String? response;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    this.response,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      category: map['category'] ?? 'other',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      assignedTo: map['assignedTo'],
      response: map['response'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'category': category,
      'title': title,
      'description': description,
      'status': status,
      'assignedTo': assignedTo,
      'response': response,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
