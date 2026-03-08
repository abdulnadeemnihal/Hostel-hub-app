import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gate_log_model.dart';
import '../services/firestore_service.dart';

class GateDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<GateLogModel> _todayLogs = [];
  List<GateLogModel> _allLogs = [];

  StreamSubscription? _todayLogsSub;
  StreamSubscription? _allLogsSub;

  List<GateLogModel> get todayLogs => _todayLogs;
  List<GateLogModel> get allLogs => _allLogs;

  int get todayExits =>
      _todayLogs.where((l) => l.action == 'exit').length;
  int get todayReturns =>
      _todayLogs.where((l) => l.action == 'return').length;
  int get currentlyOut => todayExits - todayReturns;

  void loadData() {
    _todayLogsSub?.cancel();
    _allLogsSub?.cancel();

    _todayLogsSub = _firestoreService.getTodayGateLogs().listen((data) {
      _todayLogs = data;
      notifyListeners();
    });

    _allLogsSub = _firestoreService.getAllGateLogs().listen((data) {
      _allLogs = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _todayLogsSub?.cancel();
    _allLogsSub?.cancel();
    super.dispose();
  }
}
