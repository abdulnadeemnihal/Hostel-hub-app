import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _error;
  bool _isLoading = false;
  Map<String, dynamic>? _warden;

  String? get error => _error;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get warden => _warden;
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
          _warden = await _firestoreService.getWarden(cred.user!.uid);
          // Auto-create warden document on first sign-in if it doesn't exist
          if (_warden == null) {
            final wardenData = {
              'name': 'Warden',
              'email': email,
              'role': 'warden',
              'createdAt': DateTime.now().toIso8601String(),
            };
            await _firestoreService.createWarden(cred.user!.uid, wardenData);
            _warden = wardenData;
          }
        } catch (_) {
          // Firestore may fail due to rules — still allow login
          _warden = {'name': 'Warden', 'email': email, 'role': 'warden'};
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
    _warden = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
