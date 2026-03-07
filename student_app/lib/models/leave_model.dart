import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveApplication {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String? fromTime; // HH:mm format
  final String? toTime; // HH:mm format
  final String leaveReason; // predefined category
  final String? parentPhone;
  final String destination; // place to visit
  final String modeOfTransport;
  final String description; // detailed text
  final List<String> photoUrls; // optional photos
  final bool termsAccepted;
  final String status;
  final String? wardenRemarks;
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
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'leaveType': leaveType,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'fromTime': fromTime,
      'toTime': toTime,
      'leaveReason': leaveReason,
      'parentPhone': parentPhone,
      'destination': destination,
      'modeOfTransport': modeOfTransport,
      'description': description,
      'photoUrls': photoUrls,
      'termsAccepted': termsAccepted,
      'status': status,
      'wardenRemarks': wardenRemarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get leaveDays => toDate.difference(fromDate).inDays + 1;
}
