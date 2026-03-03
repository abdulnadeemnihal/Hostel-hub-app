import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/leave_model.dart';
import '../models/meal_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/gate_pass_model.dart';
import '../models/room_model.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<StudentModel> _students = [];
  List<RoomModel> _rooms = [];
  List<ComplaintModel> _complaints = [];
  List<FeeModel> _fees = [];
  List<LeaveApplication> _leaves = [];
  List<MealMenu> _meals = [];
  List<AnnouncementModel> _announcements = [];
  List<AttendanceModel> _attendance = [];
  List<GatePassModel> _gatePasses = [];

  StreamSubscription? _studentsSub;
  StreamSubscription? _roomsSub;
  StreamSubscription? _complaintsSub;
  StreamSubscription? _feesSub;
  StreamSubscription? _leavesSub;
  StreamSubscription? _mealsSub;
  StreamSubscription? _announcementsSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _gatePassesSub;

  // ── Getters ──
  List<StudentModel> get students => _students;
  List<RoomModel> get rooms => _rooms;
  List<ComplaintModel> get complaints => _complaints;
  List<FeeModel> get fees => _fees;
  List<LeaveApplication> get leaves => _leaves;
  List<MealMenu> get meals => _meals;
  List<AnnouncementModel> get announcements => _announcements;
  List<AttendanceModel> get attendance => _attendance;
  List<GatePassModel> get gatePasses => _gatePasses;

  // ── Computed Stats ──
  int get totalStudents => _students.length;
  int get totalRooms => _rooms.length;
  int get occupiedRooms => _rooms.where((r) => r.occupied > 0).length;
  int get availableRooms => _rooms.where((r) => !r.isFull).length;
  int get pendingComplaints => _complaints.where((c) => c.status == 'pending').length;
  int get pendingLeaves => _leaves.where((l) => l.status == 'pending').length;
  int get pendingGatePasses => _gatePasses.where((g) => g.status == 'pending').length;
  double get totalCollectedFees =>
      _fees.fold<double>(0, (sum, f) => sum + f.paidAmount);
  double get totalPendingFees =>
      _fees.fold<double>(0, (sum, f) => sum + f.pendingAmount);

  void loadAllData() {
    _studentsSub?.cancel();
    _roomsSub?.cancel();
    _complaintsSub?.cancel();
    _feesSub?.cancel();
    _leavesSub?.cancel();
    _mealsSub?.cancel();
    _announcementsSub?.cancel();
    _attendanceSub?.cancel();
    _gatePassesSub?.cancel();

    _studentsSub = _firestoreService.getAllStudents().listen((data) {
      _students = data;
      notifyListeners();
    });

    _roomsSub = _firestoreService.getAllRooms().listen((data) {
      _rooms = data;
      notifyListeners();
    });

    _complaintsSub = _firestoreService.getAllComplaints().listen((data) {
      _complaints = data;
      notifyListeners();
    });

    _feesSub = _firestoreService.getAllFees().listen((data) {
      _fees = data;
      notifyListeners();
    });

    _leavesSub = _firestoreService.getAllLeaves().listen((data) {
      _leaves = data;
      notifyListeners();
    });

    _mealsSub = _firestoreService.getAllMealMenus().listen((data) {
      _meals = data;
      notifyListeners();
    });

    _announcementsSub = _firestoreService.getAllAnnouncements().listen((data) {
      _announcements = data;
      notifyListeners();
    });

    _attendanceSub = _firestoreService.getAllAttendance().listen((data) {
      _attendance = data;
      notifyListeners();
    });

    _gatePassesSub = _firestoreService.getAllGatePasses().listen((data) {
      _gatePasses = data;
      notifyListeners();
    });
  }

  // ── Room ──
  Future<void> addRoom(RoomModel room) async {
    await _firestoreService.addRoom(room);
  }

  Future<void> assignRoom(String studentId, String roomNumber, String block) async {
    await _firestoreService.updateStudent(studentId, {
      'roomNumber': roomNumber,
      'hostelBlock': block,
    });
  }

  // ── Complaints ──
  Future<void> updateComplaint(String id, String status, String? response) async {
    final data = <String, dynamic>{'status': status};
    if (response != null) data['response'] = response;
    if (status == 'resolved') data['resolvedAt'] = Timestamp.now();
    await _firestoreService.updateComplaint(id, data);
  }

  // ── Leave ──
  Future<void> updateLeave(String id, String status, String? remarks) async {
    final data = <String, dynamic>{'status': status};
    if (remarks != null) data['wardenRemarks'] = remarks;
    await _firestoreService.updateLeave(id, data);
  }

  // ── Attendance ──
  Future<void> markAttendance(AttendanceModel record) async {
    await _firestoreService.markAttendance(record);
  }

  // ── Gate Pass ──
  Future<void> updateGatePass(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateGatePass(id, data);
  }

  // ── Meals ──
  Future<void> addMealMenu(MealMenu meal) async {
    await _firestoreService.addMealMenu(meal);
  }

  Future<void> updateMealMenu(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateMealMenu(id, data);
  }

  Future<void> deleteMealMenu(String id) async {
    await _firestoreService.deleteMealMenu(id);
  }

  // ── Announcements ──
  Future<void> addAnnouncement(AnnouncementModel ann) async {
    await _firestoreService.addAnnouncement(ann);
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateAnnouncement(id, data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestoreService.deleteAnnouncement(id);
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _roomsSub?.cancel();
    _complaintsSub?.cancel();
    _feesSub?.cancel();
    _leavesSub?.cancel();
    _mealsSub?.cancel();
    _announcementsSub?.cancel();
    _attendanceSub?.cancel();
    _gatePassesSub?.cancel();
    super.dispose();
  }
}
