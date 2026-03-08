import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String rollNumber;
  final String department;
  final String branch;
  final String year;
  final String roomNumber;
  final String hostelBlock;
  final String? profileImageUrl;
  final String parentName;
  final String parentPhone;
  final String address;
  final String gender;
  final String foodPreference;
  final String roomPreference;
  final List<String> languages;
  final String referralCode;
  final DateTime createdAt;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.rollNumber,
    required this.department,
    required this.branch,
    required this.year,
    required this.roomNumber,
    required this.hostelBlock,
    this.profileImageUrl,
    required this.parentName,
    required this.parentPhone,
    required this.address,
    required this.gender,
    required this.foodPreference,
    required this.roomPreference,
    required this.languages,
    required this.referralCode,
    required this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      department: map['department'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      hostelBlock: map['hostelBlock'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      parentName: map['parentName'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      foodPreference: map['foodPreference'] ?? '',
      roomPreference: map['roomPreference'] ?? '',
      languages: List<String>.from(map['languages'] ?? []),
      referralCode: map['referralCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
