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
  final String gender; // Male, Female
  final String foodPreference; // Vegetarian, Non-Vegetarian
  final String roomPreference; // Single, Double, Triple
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'rollNumber': rollNumber,
      'department': department,
      'branch': branch,
      'year': year,
      'roomNumber': roomNumber,
      'hostelBlock': hostelBlock,
      'profileImageUrl': profileImageUrl,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'address': address,
      'gender': gender,
      'foodPreference': foodPreference,
      'roomPreference': roomPreference,
      'languages': languages,
      'referralCode': referralCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StudentModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? rollNumber,
    String? department,
    String? branch,
    String? year,
    String? roomNumber,
    String? hostelBlock,
    String? profileImageUrl,
    String? parentName,
    String? parentPhone,
    String? address,
    String? gender,
    String? foodPreference,
    String? roomPreference,
    List<String>? languages,
    String? referralCode,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      roomNumber: roomNumber ?? this.roomNumber,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      foodPreference: foodPreference ?? this.foodPreference,
      roomPreference: roomPreference ?? this.roomPreference,
      languages: languages ?? this.languages,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt,
    );
  }
}
