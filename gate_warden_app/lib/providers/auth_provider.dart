import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _error;
  bool _isLoading = false;
  Map<String, dynamic>? _gateWarden;

  String? get error => _error;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get gateWarden => _gateWarden;
  bool get isAuthenticated => _authService.currentUser != null;
  String? get uid => _authService.currentUser?.uid;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _authService.signInWithEmail(email, password);
      if (cred.user != null) {
        try {
          _gateWarden =
              await _firestoreService.getGateWarden(cred.user!.uid);
          if (_gateWarden == null) {
            final data = {
              'name': 'Gate Warden',
              'email': email,
              'role': 'gate_warden',
              'createdAt': DateTime.now().toIso8601String(),
            };
            await _firestoreService.createGateWarden(cred.user!.uid, data);
            _gateWarden = data;
          }
        } catch (_) {
          _gateWarden = {
            'name': 'Gate Warden',
            'email': email,
            'role': 'gate_warden'
          };
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _gateWarden = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
