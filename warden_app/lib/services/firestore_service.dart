import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/leave_model.dart';
import '../models/meal_model.dart';
import '../models/meal_poll_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/gate_pass_model.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';
import '../utils/default_meal_data.dart';

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

  /// Seeds the default 7-day Veg + Non-Veg menus if the collection is empty.
  Future<void> seedDefaultMenus() async {
    final snap = await _db.collection(AppConstants.mealsCollection).limit(1).get();
    if (snap.docs.isNotEmpty) return; // Already has data

    final batch = _db.batch();
    final now = DateTime.now();

    for (final item in defaultVegetarianMenu) {
      final ref = _db.collection(AppConstants.mealsCollection).doc();
      batch.set(ref, {
        'day': item['day'],
        'foodType': 'Vegetarian',
        'breakfast': item['breakfast'],
        'lunch': item['lunch'],
        'snacks': item['snacks'],
        'dinner': item['dinner'],
        'weekStartDate': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
      });
    }

    for (final item in defaultNonVegetarianMenu) {
      final ref = _db.collection(AppConstants.mealsCollection).doc();
      batch.set(ref, {
        'day': item['day'],
        'foodType': 'Non-Vegetarian',
        'breakfast': item['breakfast'],
        'lunch': item['lunch'],
        'snacks': item['snacks'],
        'dinner': item['dinner'],
        'weekStartDate': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
      });
    }

    await batch.commit();
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

  // ── Meal Polls ──
  Stream<List<MealPoll>> getAllPolls() {
    return _db
        .collection(AppConstants.mealPollsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealPoll.fromMap(d.data(), d.id)).toList());
  }

  Future<void> createPoll(MealPoll poll) async {
    await _db.collection(AppConstants.mealPollsCollection).add(poll.toMap());
  }

  Future<void> closePollAndApply(String pollId) async {
    await _db.runTransaction((tx) async {
      final pollRef =
          _db.collection(AppConstants.mealPollsCollection).doc(pollId);
      final pollSnap = await tx.get(pollRef);
      if (!pollSnap.exists) return;

      final poll = MealPoll.fromMap(pollSnap.data()!, pollSnap.id);
      if (poll.status != 'active') return;

      // Determine winner (option with most votes)
      String? winnerName;
      int maxVotes = 0;
      for (final opt in poll.options) {
        if (opt.votes > maxVotes) {
          maxVotes = opt.votes;
          winnerName = opt.name;
        }
      }

      tx.update(pollRef, {
        'status': 'closed',
        'winner': winnerName,
        'appliedToMenu': winnerName != null,
      });

      // Apply winner to matching meal menu(s)
      if (winnerName != null) {
        final mealField = _mealTypeToField(poll.mealType);
        final foodTypes = poll.foodType == 'Both'
            ? ['Vegetarian', 'Non-Vegetarian']
            : [poll.foodType];

        for (final ft in foodTypes) {
          final menuSnap = await _db
              .collection(AppConstants.mealsCollection)
              .where('day', isEqualTo: poll.targetDay)
              .where('foodType', isEqualTo: ft)
              .limit(1)
              .get();
          if (menuSnap.docs.isNotEmpty) {
            tx.update(menuSnap.docs.first.reference, {mealField: winnerName});
          }
        }
      }
    });
  }

  Future<void> deletePoll(String id) async {
    await _db.collection(AppConstants.mealPollsCollection).doc(id).delete();
  }

  String _mealTypeToField(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return 'breakfast';
      case 'Lunch':
        return 'lunch';
      case 'Snack':
        return 'snacks';
      case 'Dinner':
        return 'dinner';
      default:
        return 'breakfast';
    }
  }
}
