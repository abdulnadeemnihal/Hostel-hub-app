import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import '../models/block_model.dart';
import '../models/floor_config_model.dart';
import '../services/firestore_service.dart';
import '../services/block_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final BlockService _blockService = BlockService();

  List<StudentModel> _students = [];
  List<RoomModel> _rooms = [];
  List<BlockModel> _blocks = [];
  List<ComplaintModel> _complaints = [];
  List<FeeModel> _fees = [];
  List<LeaveApplication> _leaves = [];
  List<MealMenu> _meals = [];
  List<MealPoll> _polls = [];
  List<AnnouncementModel> _announcements = [];
  List<AttendanceModel> _attendance = [];
  List<GatePassModel> _gatePasses = [];

  StreamSubscription? _studentsSub;
  StreamSubscription? _roomsSub;
  StreamSubscription? _blocksSub;
  StreamSubscription? _complaintsSub;
  StreamSubscription? _feesSub;
  StreamSubscription? _leavesSub;
  StreamSubscription? _mealsSub;
  StreamSubscription? _pollsSub;
  StreamSubscription? _announcementsSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _gatePassesSub;

  // ── Getters ──
  List<StudentModel> get students => _students;
  List<RoomModel> get rooms => _rooms;
  List<BlockModel> get blocks => _blocks;
  List<ComplaintModel> get complaints => _complaints;
  List<FeeModel> get fees => _fees;
  List<LeaveApplication> get leaves => _leaves;
  List<MealMenu> get meals => _meals;
  List<MealPoll> get polls => _polls;
  List<AnnouncementModel> get announcements => _announcements;
  List<AttendanceModel> get attendance => _attendance;
  List<GatePassModel> get gatePasses => _gatePasses;

  // ── Computed Stats ──
  int get totalStudents => _students.length;
  int get totalRooms => _rooms.length;
  int get occupiedRooms => _rooms.where((r) => r.occupied > 0).length;
  int get availableRooms => _rooms.where((r) => !r.isFull).length;
  int get pendingComplaints =>
      _complaints.where((c) => c.status == 'pending').length;
  int get pendingLeaves => _leaves.where((l) => l.status == 'pending').length;
  int get pendingGatePasses =>
      _gatePasses.where((g) => g.status == 'pending').length;
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
    _pollsSub?.cancel();
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

    _blocksSub = _blockService.getAllBlocks().listen((data) {
      _blocks = data;
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

    _pollsSub = _firestoreService.getAllPolls().listen((data) {
      _polls = data;
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

  Future<void> createBlock(BlockModel block) async {
    final ref = await _blockService.addBlock(block);
    final blockId = ref.id;
    final rooms = _generateRoomsForBlock(block, blockId);
    await Future.wait(rooms.map((room) => _blockService.addRoom(room)));
  }

  Future<void> deleteBlock(String id) async {
    await _blockService.deleteRoomsForBlock(id);
    await _blockService.deleteBlock(id);
  }

  Future<void> updateBlock(BlockModel block, {bool rebuildRooms = false}) async {
    await _blockService.updateBlock(block.id, block.toMap());
    if (rebuildRooms) {
      await _blockService.deleteRoomsForBlock(block.id);
      final rooms = _generateRoomsForBlock(block, block.id);
      await Future.wait(rooms.map((room) => _blockService.addRoom(room)));
    }
  }

  Future<void> deleteRoom(String roomId) async {
    await _blockService.deleteRoom(roomId);
  }

  List<RoomModel> roomsForBlock(String blockId) {
    return _rooms.where((room) => room.blockId == blockId).toList();
  }

  List<RoomModel> roomsForFloor(String blockId, int floor) {
    return _rooms
        .where((room) => room.blockId == blockId && room.floor == floor)
        .toList();
  }

  List<RoomModel> filterRooms({
    String? blockId,
    int? floor,
    int? sharing,
    bool? isAvailable,
  }) {
    return _rooms.where((room) {
      if (blockId != null && room.blockId != blockId) return false;
      if (floor != null && room.floor != floor) return false;
      if (sharing != null && room.capacity != sharing) return false;
      if (isAvailable != null && room.isAvailable != isAvailable) return false;
      return true;
    }).toList();
  }

  Future<void> assignRoom(
    String studentId,
    String roomNumber,
    String block,
  ) async {
    await _firestoreService.updateStudent(studentId, {
      'roomNumber': roomNumber,
      'hostelBlock': block,
    });
  }

  List<RoomModel> _generateRoomsForBlock(BlockModel block, String blockId) {
    final rooms = <RoomModel>[];
    for (var floorIndex = 1; floorIndex <= block.floorCount; floorIndex++) {
      final config = block.sameRoomsPerFloor
          ? FloorConfig(
              floorNumber: floorIndex,
              roomsCount: block.roomsPerFloor,
              roomSharings: block.floors.isNotEmpty
                  ? block.floors.first.roomSharings
                  : [],
            )
          : block.floors.firstWhere(
              (floor) => floor.floorNumber == floorIndex,
              orElse: () => FloorConfig(
                floorNumber: floorIndex,
                roomsCount: 0,
                roomSharings: [],
              ),
            );

      for (var roomIndex = 0; roomIndex < config.roomsCount; roomIndex++) {
        final capacity = roomIndex < config.roomSharings.length
            ? config.roomSharings[roomIndex]
            : 2;
        final roomNumber = '${floorIndex}${(roomIndex + 1).toString().padLeft(2, '0')}';
        rooms.add(RoomModel(
          id: '',
          roomNumber: roomNumber,
          block: block.name,
          blockId: blockId,
          floor: floorIndex,
          capacity: capacity,
          occupied: 0,
          roomType: _roomTypeFromCapacity(capacity),
          occupantIds: [],
          occupantNames: [],
          isAvailable: true,
          amenities: ['Wi-Fi', 'Fan', 'Desk', 'Cupboard', 'Bed'],
        ));
      }
    }
    return rooms;
  }

  String _roomTypeFromCapacity(int capacity) {
    switch (capacity) {
      case 1:
        return 'Single';
      case 2:
        return 'Double';
      case 3:
        return 'Triple';
      case 4:
        return 'Quad';
      default:
        return 'Shared';
    }
  }

  // ── Complaints ──
  Future<void> updateComplaint(
    String id,
    String status,
    String? response,
  ) async {
    final data = <String, dynamic>{'status': status};
    if (response != null) data['response'] = response;
    if (status == 'fixed') data['resolvedAt'] = Timestamp.now();
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

  // ── Polls ──
  Future<void> createPoll(MealPoll poll) async {
    await _firestoreService.createPoll(poll);
  }

  Future<void> closePollAndApply(String pollId) async {
    await _firestoreService.closePollAndApply(pollId);
  }

  Future<void> deletePoll(String id) async {
    await _firestoreService.deletePoll(id);
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
    _blocksSub?.cancel();
    _complaintsSub?.cancel();
    _feesSub?.cancel();
    _leavesSub?.cancel();
    _mealsSub?.cancel();
    _pollsSub?.cancel();
    _announcementsSub?.cancel();
    _attendanceSub?.cancel();
    _gatePassesSub?.cancel();
    super.dispose();
  }
}
