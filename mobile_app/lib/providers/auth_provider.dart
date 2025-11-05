import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        await _loadUserProfile(_currentUser!.id);
      }
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Firebase
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.signIn(email, password);
      
      if (_currentUser != null) {
        // Load user profile from Firestore
        await _loadUserProfile(_currentUser!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with Firebase
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.signUp(email, password, name);
      
      if (_currentUser != null) {
        // Save user profile to Firestore
        await _firestore.addDocument('users', {
          'id': _currentUser!.id,
          'name': name,
          'email': email,
          'photoUrl': null,
          'createdAt': DateTime.now().toIso8601String(),
        });
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load current user
  Future<void> loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.id);
    }
    notifyListeners();
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userData = await _firestore.getDocument('users', userId);
      if (userData != null && _currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: userData['name'] ?? _currentUser!.name,
          photoUrl: userData['photoUrl'],
          createdAt: _currentUser!.createdAt,
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Convert Firebase error to friendly message
  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Email không tồn tại';
    } else if (error.contains('wrong-password')) {
      return 'Mật khẩu không đúng';
    } else if (error.contains('email-already-in-use')) {
      return 'Email đã được sử dụng';
    } else if (error.contains('weak-password')) {
      return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
    } else if (error.contains('invalid-email')) {
      return 'Email không hợp lệ';
    } else if (error.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng';
    } else if (error.contains('too-many-requests')) {
      return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
    }
    return 'Đã có lỗi xảy ra';
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}








