import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final DateTime date;
  final String status;
  final String? markedBy;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.date,
    required this.status,
    this.markedBy,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'absent',
      markedBy: map['markedBy'],
      checkInTime: (map['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (map['checkOutTime'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'date': Timestamp.fromDate(date),
      'status': status,
      'markedBy': markedBy,
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
