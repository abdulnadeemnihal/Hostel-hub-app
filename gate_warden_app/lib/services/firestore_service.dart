import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/leave_model.dart';
import '../models/gate_pass_model.dart';
import '../models/gate_log_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Gate Warden ──
  Future<void> createGateWarden(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.gateWardensCollection).doc(uid).set(data);
  }

  Future<Map<String, dynamic>?> getGateWarden(String uid) async {
    final doc =
        await _db.collection(AppConstants.gateWardensCollection).doc(uid).get();
    return doc.data();
  }

  // ── Student Lookup ──
  Future<StudentModel?> getStudent(String uid) async {
    final doc =
        await _db.collection(AppConstants.studentsCollection).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return StudentModel.fromMap(doc.data()!, doc.id);
  }

  // ── Leave Lookup ──
  /// Get approved leaves for a student that cover today's date.
  Future<List<LeaveApplication>> getActiveLeaves(String studentId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.leaveCollection)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'approved')
        .get();

    return snap.docs
        .map((d) => LeaveApplication.fromMap(d.data(), d.id))
        .where((leave) {
      // Leave period must overlap with today
      return leave.fromDate.isBefore(todayEnd) &&
          leave.toDate
              .add(const Duration(days: 1))
              .isAfter(todayStart);
    }).toList();
  }

  /// Get all approved leaves for a student (not just today).
  Future<List<LeaveApplication>> getAllApprovedLeaves(String studentId) async {
    final snap = await _db
        .collection(AppConstants.leaveCollection)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => LeaveApplication.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateLeave(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.leaveCollection).doc(id).update(data);
  }

  // ── Gate Pass Lookup ──
  /// Get approved gate passes for a student that cover today.
  Future<List<GatePassModel>> getActiveGatePasses(String studentId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.gatePassCollection)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'approved')
        .get();

    return snap.docs
        .map((d) => GatePassModel.fromMap(d.data(), d.id))
        .where((pass) {
      return pass.outDate.isBefore(todayEnd) &&
          pass.expectedReturnDate
              .add(const Duration(days: 1))
              .isAfter(todayStart);
    }).toList();
  }

  Future<void> updateGatePass(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.gatePassCollection).doc(id).update(data);
  }

  // ── Gate Logs ──
  Future<void> addGateLog(GateLogModel log) async {
    await _db.collection(AppConstants.gateLogsCollection).add(log.toMap());
  }

  Stream<List<GateLogModel>> getTodayGateLogs() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return _db
        .collection(AppConstants.gateLogsCollection)
        .where('scannedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GateLogModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<GateLogModel>> getAllGateLogs() {
    return _db
        .collection(AppConstants.gateLogsCollection)
        .orderBy('scannedAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GateLogModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Currently Out Students ──
  /// Get all leaves where gateStatus is 'out' (student hasn't returned).
  Stream<List<LeaveApplication>> getStudentsCurrentlyOut() {
    return _db
        .collection(AppConstants.leaveCollection)
        .where('gateStatus', isEqualTo: 'out')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LeaveApplication.fromMap(d.data(), d.id))
            .toList());
  }
}
