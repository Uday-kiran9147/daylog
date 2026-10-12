import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  AuthViewModel({required this.authService}) {
    _currentUser = authService.currentUser;
    _authSubscription = authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both email and password.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseFirebaseAuthException(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in all fields.';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await authService.signUpWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseFirebaseAuthException(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Account creation failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter your email address.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await authService.sendPasswordResetEmail(email);
      _successMessage =
          'Password reset link sent to $email. Please check your inbox.';
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseFirebaseAuthException(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Unable to send reset email. Please verify your address.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _parseFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'Password is too weak. Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
