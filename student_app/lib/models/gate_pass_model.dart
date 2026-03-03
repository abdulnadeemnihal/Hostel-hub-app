import 'package:cloud_firestore/cloud_firestore.dart';

class GatePassModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String reason;
  final String destination;
  final DateTime outDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final String status;
  final String? approvedBy;
  final String? wardenRemarks;
  final DateTime createdAt;

  GatePassModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.reason,
    required this.destination,
    required this.outDate,
    required this.expectedReturnDate,
    this.actualReturnDate,
    required this.status,
    this.approvedBy,
    this.wardenRemarks,
    required this.createdAt,
  });

  factory GatePassModel.fromMap(Map<String, dynamic> map, String id) {
    return GatePassModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      reason: map['reason'] ?? '',
      destination: map['destination'] ?? '',
      outDate: (map['outDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expectedReturnDate: (map['expectedReturnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actualReturnDate: (map['actualReturnDate'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'pending',
      approvedBy: map['approvedBy'],
      wardenRemarks: map['wardenRemarks'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'reason': reason,
      'destination': destination,
      'outDate': Timestamp.fromDate(outDate),
      'expectedReturnDate': Timestamp.fromDate(expectedReturnDate),
      'actualReturnDate': actualReturnDate != null ? Timestamp.fromDate(actualReturnDate!) : null,
      'status': status,
      'approvedBy': approvedBy,
      'wardenRemarks': wardenRemarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
