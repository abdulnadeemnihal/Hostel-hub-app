import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String category;
  final String subCategory;
  final String urgency;
  final String description;
  final String status; // pending, processing, fixed
  final List<String> photos;
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
    required this.subCategory,
    required this.urgency,
    required this.description,
    required this.status,
    this.photos = const [],
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
      category: map['category'] ?? 'Maintenance',
      subCategory: map['subCategory'] ?? '',
      urgency: map['urgency'] ?? 'Basic',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      photos: List<String>.from(map['photos'] ?? []),
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
      'subCategory': subCategory,
      'urgency': urgency,
      'description': description,
      'status': status,
      'photos': photos,
      'assignedTo': assignedTo,
      'response': response,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
