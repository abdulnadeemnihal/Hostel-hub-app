import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/leave_model.dart';
import '../models/meal_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/gate_pass_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Student ──
  Future<StudentModel?> getStudent(String uid) async {
    final doc = await _db.collection(AppConstants.studentsCollection).doc(uid).get();
    if (doc.exists) {
      return StudentModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> createStudent(StudentModel student) async {
    await _db
        .collection(AppConstants.studentsCollection)
        .doc(student.uid)
        .set(student.toMap());
  }

  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.studentsCollection).doc(uid).update(data);
  }

  // ── Complaints ──
  Stream<List<ComplaintModel>> getStudentComplaints(String studentId) {
    return _db
        .collection(AppConstants.complaintsCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ComplaintModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addComplaint(ComplaintModel complaint) async {
    await _db.collection(AppConstants.complaintsCollection).add(complaint.toMap());
  }

  // ── Fees ──
  Stream<List<FeeModel>> getStudentFees(String studentId) {
    return _db
        .collection(AppConstants.feesCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FeeModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Leave Applications ──
  Stream<List<LeaveApplication>> getStudentLeaves(String studentId) {
    return _db
        .collection(AppConstants.leaveCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LeaveApplication.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addLeave(LeaveApplication leave) async {
    await _db.collection(AppConstants.leaveCollection).add(leave.toMap());
  }

  // ── Meal Menus ──
  Stream<List<MealMenu>> getMealMenus() {
    return _db
        .collection(AppConstants.mealsCollection)
        .orderBy('day')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealMenu.fromMap(d.data(), d.id)).toList());
  }

  // ── Announcements ──
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _db
        .collection(AppConstants.announcementsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AnnouncementModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Attendance ──
  Stream<List<AttendanceModel>> getStudentAttendance(String studentId) {
    return _db
        .collection(AppConstants.attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AttendanceModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Gate Passes ──
  Stream<List<GatePassModel>> getStudentGatePasses(String studentId) {
    return _db
        .collection(AppConstants.gatePassCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GatePassModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addGatePass(GatePassModel gatePass) async {
    await _db.collection(AppConstants.gatePassCollection).add(gatePass.toMap());
  }
}
