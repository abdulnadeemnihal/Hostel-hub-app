import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveApplication {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String? fromTime;
  final String? toTime;
  final String leaveReason;
  final String? parentPhone;
  final String destination;
  final String modeOfTransport;
  final String description;
  final List<String> photoUrls;
  final bool termsAccepted;
  final String status;
  final String? wardenRemarks;
  final String? gateStatus; // 'in' | 'out'
  final DateTime? gateExitTime;
  final DateTime? gateReturnTime;
  final String? gateVerifiedBy;
  final DateTime createdAt;

  LeaveApplication({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    this.fromTime,
    this.toTime,
    required this.leaveReason,
    this.parentPhone,
    required this.destination,
    required this.modeOfTransport,
    required this.description,
    this.photoUrls = const [],
    this.termsAccepted = false,
    required this.status,
    this.wardenRemarks,
    this.gateStatus,
    this.gateExitTime,
    this.gateReturnTime,
    this.gateVerifiedBy,
    required this.createdAt,
  });

  factory LeaveApplication.fromMap(Map<String, dynamic> map, String id) {
    return LeaveApplication(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      leaveType: map['leaveType'] ?? 'Personal',
      fromDate: (map['fromDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      toDate: (map['toDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fromTime: map['fromTime'],
      toTime: map['toTime'],
      leaveReason: map['leaveReason'] ?? '',
      parentPhone: map['parentPhone'],
      destination: map['destination'] ?? '',
      modeOfTransport: map['modeOfTransport'] ?? '',
      description: map['description'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      termsAccepted: map['termsAccepted'] ?? false,
      status: map['status'] ?? 'pending',
      wardenRemarks: map['wardenRemarks'],
      gateStatus: map['gateStatus'],
      gateExitTime: (map['gateExitTime'] as Timestamp?)?.toDate(),
      gateReturnTime: (map['gateReturnTime'] as Timestamp?)?.toDate(),
      gateVerifiedBy: map['gateVerifiedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  int get leaveDays => toDate.difference(fromDate).inDays + 1;
}
