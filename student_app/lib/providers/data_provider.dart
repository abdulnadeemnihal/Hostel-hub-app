import 'dart:async';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/leave_model.dart';
import '../models/meal_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/gate_pass_model.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ComplaintModel> _complaints = [];
  List<FeeModel> _fees = [];
  List<LeaveApplication> _leaves = [];
  List<MealMenu> _mealMenus = [];
  List<AnnouncementModel> _announcements = [];
  List<AttendanceModel> _attendance = [];
  List<GatePassModel> _gatePasses = [];

  StreamSubscription? _complaintsSub;
  StreamSubscription? _feesSub;
  StreamSubscription? _leavesSub;
  StreamSubscription? _mealsSub;
  StreamSubscription? _announcementsSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _gatePassesSub;

  List<ComplaintModel> get complaints => _complaints;
  List<FeeModel> get fees => _fees;
  List<LeaveApplication> get leaves => _leaves;
  List<MealMenu> get mealMenus => _mealMenus;
  List<AnnouncementModel> get announcements => _announcements;
  List<AttendanceModel> get attendance => _attendance;
  List<GatePassModel> get gatePasses => _gatePasses;

  double get totalPendingFees =>
      _fees.fold<double>(0, (sum, f) => sum + f.pendingAmount);

  void loadStudentData(String studentId) {
    _complaintsSub?.cancel();
    _feesSub?.cancel();
    _leavesSub?.cancel();
    _mealsSub?.cancel();
    _announcementsSub?.cancel();
    _attendanceSub?.cancel();
    _gatePassesSub?.cancel();

    _complaintsSub = _firestoreService.getStudentComplaints(studentId).listen((data) {
      _complaints = data;
      notifyListeners();
    });

    _feesSub = _firestoreService.getStudentFees(studentId).listen((data) {
      _fees = data;
      notifyListeners();
    });

    _leavesSub = _firestoreService.getStudentLeaves(studentId).listen((data) {
      _leaves = data;
      notifyListeners();
    });

    _mealsSub = _firestoreService.getMealMenus().listen((data) {
      _mealMenus = data;
      notifyListeners();
    });

    _announcementsSub = _firestoreService.getAnnouncements().listen((data) {
      _announcements = data;
      notifyListeners();
    });

    _attendanceSub = _firestoreService.getStudentAttendance(studentId).listen((data) {
      _attendance = data;
      notifyListeners();
    });

    _gatePassesSub = _firestoreService.getStudentGatePasses(studentId).listen((data) {
      _gatePasses = data;
      notifyListeners();
    });
  }

  Future<void> addComplaint(ComplaintModel complaint) async {
    await _firestoreService.addComplaint(complaint);
  }

  Future<void> addLeave(LeaveApplication leave) async {
    await _firestoreService.addLeave(leave);
  }

  Future<void> addGatePass(GatePassModel gatePass) async {
    await _firestoreService.addGatePass(gatePass);
  }

  @override
  void dispose() {
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
