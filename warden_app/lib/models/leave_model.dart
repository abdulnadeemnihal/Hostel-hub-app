import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveApplication {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String reason;
  final String leaveType; // home, medical, personal, emergency
  final DateTime fromDate;
  final DateTime toDate;
  final String status; // pending, approved, rejected
  final String? wardenRemarks;
  final String? parentPhone;
  final String destination;
  final DateTime createdAt;

  LeaveApplication({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.reason,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.status,
    this.wardenRemarks,
    this.parentPhone,
    required this.destination,
    required this.createdAt,
  });

  factory LeaveApplication.fromMap(Map<String, dynamic> map, String id) {
    return LeaveApplication(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      reason: map['reason'] ?? '',
      leaveType: map['leaveType'] ?? 'personal',
      fromDate: (map['fromDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      toDate: (map['toDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      wardenRemarks: map['wardenRemarks'],
      parentPhone: map['parentPhone'],
      destination: map['destination'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'reason': reason,
      'leaveType': leaveType,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'status': status,
      'wardenRemarks': wardenRemarks,
      'parentPhone': parentPhone,
      'destination': destination,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get leaveDays => toDate.difference(fromDate).inDays + 1;
}
