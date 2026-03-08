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
  final String? gateStatus; // 'in' | 'out'
  final DateTime? gateExitTime;
  final DateTime? gateReturnTime;
  final String? gateVerifiedBy;
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
    this.gateStatus,
    this.gateExitTime,
    this.gateReturnTime,
    this.gateVerifiedBy,
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
      gateStatus: map['gateStatus'],
      gateExitTime: (map['gateExitTime'] as Timestamp?)?.toDate(),
      gateReturnTime: (map['gateReturnTime'] as Timestamp?)?.toDate(),
      gateVerifiedBy: map['gateVerifiedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
