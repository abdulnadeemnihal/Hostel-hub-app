import 'package:cloud_firestore/cloud_firestore.dart';

class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String feeType;
  final double amount;
  final double paidAmount;
  final String status;
  final String semester;
  final String academicYear;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? transactionId;
  final DateTime createdAt;

  FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.feeType,
    required this.amount,
    required this.paidAmount,
    required this.status,
    required this.semester,
    required this.academicYear,
    required this.dueDate,
    this.paidDate,
    this.transactionId,
    required this.createdAt,
  });

  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    return FeeModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      feeType: map['feeType'] ?? 'hostel',
      amount: (map['amount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      semester: map['semester'] ?? '',
      academicYear: map['academicYear'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate: (map['paidDate'] as Timestamp?)?.toDate(),
      transactionId: map['transactionId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'feeType': feeType,
      'amount': amount,
      'paidAmount': paidAmount,
      'status': status,
      'semester': semester,
      'academicYear': academicYear,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get pendingAmount => amount - paidAmount;
  bool get isPaid => status == 'paid';
}
