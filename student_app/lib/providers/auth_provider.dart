import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  StudentModel? _student;
  String? _error;
  bool _isLoading = false;

  StudentModel? get student => _student;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.currentUser != null;

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
        _student = await _firestoreService.getStudent(cred.user!.uid);
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
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String rollNumber,
    required String department,
    required String branch,
    required String year,
    required String parentName,
    required String parentPhone,
    required String address,
    required String gender,
    required String foodPreference,
    required String roomPreference,
    required List<String> languages,
    required String referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _authService.signUpWithEmail(email, password);
      if (cred.user != null) {
        final student = StudentModel(
          uid: cred.user!.uid,
          name: name,
          email: email,
          phone: phone,
          rollNumber: rollNumber,
          department: department,
          branch: branch,
          year: year,
          roomNumber: '',
          hostelBlock: '',
          parentName: parentName,
          parentPhone: parentPhone,
          address: address,
          gender: gender,
          foodPreference: foodPreference,
          roomPreference: roomPreference,
          languages: languages,
          referralCode: referralCode,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createStudent(student);
        _student = student;
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
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = 'Failed to send reset email.';
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_student == null) return;
    try {
      await _firestoreService.updateStudent(_student!.uid, data);
      _student = await _firestoreService.getStudent(_student!.uid);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile.';
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      _student = await _firestoreService.getStudent(user.uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _student = null;
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
