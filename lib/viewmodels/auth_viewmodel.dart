import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:total_x/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
