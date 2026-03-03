import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/leave_model.dart';
import '../models/meal_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/gate_pass_model.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Warden ──
  Future<void> createWarden(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.wardensCollection).doc(uid).set(data);
  }

  Future<Map<String, dynamic>?> getWarden(String uid) async {
    final doc = await _db.collection(AppConstants.wardensCollection).doc(uid).get();
    return doc.data();
  }

  // ── Students ──
  Stream<List<StudentModel>> getAllStudents() {
    return _db
        .collection(AppConstants.studentsCollection)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StudentModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.studentsCollection).doc(uid).update(data);
  }

  // ── Rooms ──
  Stream<List<RoomModel>> getAllRooms() {
    return _db
        .collection(AppConstants.roomsCollection)
        .orderBy('roomNumber')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RoomModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addRoom(RoomModel room) async {
    await _db.collection(AppConstants.roomsCollection).add(room.toMap());
  }

  // ── Complaints ──
  Stream<List<ComplaintModel>> getAllComplaints() {
    return _db
        .collection(AppConstants.complaintsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ComplaintModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateComplaint(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.complaintsCollection).doc(id).update(data);
  }

  // ── Fees ──
  Stream<List<FeeModel>> getAllFees() {
    return _db
        .collection(AppConstants.feesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FeeModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Leave Applications ──
  Stream<List<LeaveApplication>> getAllLeaves() {
    return _db
        .collection(AppConstants.leaveCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LeaveApplication.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateLeave(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.leaveCollection).doc(id).update(data);
  }

  // ── Meal Menus ──
  Stream<List<MealMenu>> getAllMealMenus() {
    return _db
        .collection(AppConstants.mealsCollection)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealMenu.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addMealMenu(MealMenu meal) async {
    await _db.collection(AppConstants.mealsCollection).add(meal.toMap());
  }

  Future<void> updateMealMenu(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.mealsCollection).doc(id).update(data);
  }

  Future<void> deleteMealMenu(String id) async {
    await _db.collection(AppConstants.mealsCollection).doc(id).delete();
  }

  // ── Announcements ──
  Stream<List<AnnouncementModel>> getAllAnnouncements() {
    return _db
        .collection(AppConstants.announcementsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AnnouncementModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addAnnouncement(AnnouncementModel ann) async {
    await _db.collection(AppConstants.announcementsCollection).add(ann.toMap());
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.announcementsCollection).doc(id).update(data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection(AppConstants.announcementsCollection).doc(id).delete();
  }

  // ── Attendance ──
  Stream<List<AttendanceModel>> getAllAttendance() {
    return _db
        .collection(AppConstants.attendanceCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AttendanceModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> markAttendance(AttendanceModel record) async {
    await _db.collection(AppConstants.attendanceCollection).add(record.toMap());
  }

  // ── Gate Passes ──
  Stream<List<GatePassModel>> getAllGatePasses() {
    return _db
        .collection(AppConstants.gatePassCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GatePassModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateGatePass(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.gatePassCollection).doc(id).update(data);
  }
}
