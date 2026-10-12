import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  User? _user;
  final _controller = StreamController<User?>.broadcast();

  MockAuthService({User? initialUser}) : _user = initialUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    if (email.contains('error')) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Invalid email or password.',
      );
    }
    // Simulate auth success
    _controller.add(_user);
    return _createMockUserCredential(email);
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    if (email.contains('exists')) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'An account already exists with this email.',
      );
    }
    _controller.add(_user);
    return _createMockUserCredential(email);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.contains('notfound')) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email.',
      );
    }
    // Success
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  UserCredential _createMockUserCredential(String email) {
    return _MockUserCredential();
  }

  void dispose() {
    _controller.close();
  }
}

class _MockUserCredential implements UserCredential {
  @override
  final AuthCredential? credential = null;

  @override
  final AdditionalUserInfo? additionalUserInfo = null;

  @override
  final User? user = null;
}
