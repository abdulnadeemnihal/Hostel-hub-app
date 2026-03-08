import 'package:cloud_firestore/cloud_firestore.dart';

/// A log entry for every gate scan event (exit or return).
class GateLogModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String action; // 'exit' | 'return'
  final String passType; // 'leave' | 'gate_pass'
  final String passId; // leave or gate_pass document ID
  final String scannedBy; // gate warden UID
  final DateTime scannedAt;

  GateLogModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.action,
    required this.passType,
    required this.passId,
    required this.scannedBy,
    required this.scannedAt,
  });

  factory GateLogModel.fromMap(Map<String, dynamic> map, String id) {
    return GateLogModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      action: map['action'] ?? '',
      passType: map['passType'] ?? '',
      passId: map['passId'] ?? '',
      scannedBy: map['scannedBy'] ?? '',
      scannedAt: (map['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'action': action,
      'passType': passType,
      'passId': passId,
      'scannedBy': scannedBy,
      'scannedAt': Timestamp.fromDate(scannedAt),
    };
  }
}
