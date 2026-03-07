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
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Student ──
  Future<StudentModel?> getStudent(String uid) async {
    final doc = await _db
        .collection(AppConstants.studentsCollection)
        .doc(uid)
        .get();
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
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ComplaintModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> addComplaint(ComplaintModel complaint) async {
    await _db
        .collection(AppConstants.complaintsCollection)
        .add(complaint.toMap());
  }

  Future<void> updateComplaint(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.complaintsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteComplaint(String id) async {
    await _db.collection(AppConstants.complaintsCollection).doc(id).delete();
  }

  // ── Fees ──
  Stream<List<FeeModel>> getStudentFees(String studentId) {
    return _db
        .collection(AppConstants.feesCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FeeModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // ── Leave Applications ──
  Stream<List<LeaveApplication>> getStudentLeaves(String studentId) {
    return _db
        .collection(AppConstants.leaveCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => LeaveApplication.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> addLeave(LeaveApplication leave) async {
    await _db.collection(AppConstants.leaveCollection).add(leave.toMap());
  }

  Future<void> updateLeave(String leaveId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.leaveCollection)
        .doc(leaveId)
        .update(data);
  }

  Future<void> deleteLeave(String leaveId) async {
    await _db.collection(AppConstants.leaveCollection).doc(leaveId).delete();
  }

  // ── Meal Menus ──
  Stream<List<MealMenu>> getMealMenus({String? foodType}) {
    Query<Map<String, dynamic>> query =
        _db.collection(AppConstants.mealsCollection);
    if (foodType != null) {
      query = query.where('foodType', isEqualTo: foodType);
    }
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => MealMenu.fromMap(d.data(), d.id))
          .toList();
      // Sort by day-of-week order (Mon→Sun)
      const dayOrder = {
        'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
        'Friday': 5, 'Saturday': 6, 'Sunday': 7,
      };
      list.sort((a, b) =>
          (dayOrder[a.day] ?? 8).compareTo(dayOrder[b.day] ?? 8));
      return list;
    });
  }

  // ── Announcements ──
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _db.collection(AppConstants.announcementsCollection).snapshots().map(
      (snap) {
        final list = snap.docs
            .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      },
    );
  }

  // ── Attendance ──
  Stream<List<AttendanceModel>> getStudentAttendance(String studentId) {
    return _db
        .collection(AppConstants.attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => AttendanceModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ── Gate Passes ──
  Stream<List<GatePassModel>> getStudentGatePasses(String studentId) {
    return _db
        .collection(AppConstants.gatePassCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => GatePassModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> addGatePass(GatePassModel gatePass) async {
    await _db.collection(AppConstants.gatePassCollection).add(gatePass.toMap());
  }

  // ── Meal Polls ──
  Stream<List<MealPoll>> getActivePolls() {
    return _db
        .collection(AppConstants.mealPollsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MealPoll.fromMap(d.data(), d.id))
            .where((p) => p.status == 'active')
            .toList());
  }

  Future<void> submitVote(
      String pollId, String studentId, int optionIndex) async {
    final pollRef =
        _db.collection(AppConstants.mealPollsCollection).doc(pollId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(pollRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final voters = Map<String, dynamic>.from(data['voters'] ?? {});
      if (voters.containsKey(studentId)) return; // Already voted

      final options = List<Map<String, dynamic>>.from(
          (data['options'] as List).map((e) => Map<String, dynamic>.from(e)));
      if (optionIndex < 0 || optionIndex >= options.length) return;

      options[optionIndex]['votes'] = (options[optionIndex]['votes'] ?? 0) + 1;
      voters[studentId] = optionIndex;

      tx.update(pollRef, {'options': options, 'voters': voters});
    });
  }

  /// Auto-close expired poll and apply winner to menu.
  Future<void> autoClosePollIfExpired(String pollId) async {
    await _db.runTransaction((tx) async {
      final pollRef =
          _db.collection(AppConstants.mealPollsCollection).doc(pollId);
      final snap = await tx.get(pollRef);
      if (!snap.exists) return;

      final poll = MealPoll.fromMap(snap.data()!, snap.id);
      if (poll.status != 'active') return;
      if (!poll.isExpired) return;

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
