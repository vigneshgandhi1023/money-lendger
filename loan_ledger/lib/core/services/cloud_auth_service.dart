import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the CloudAuthService instance.
final cloudAuthProvider = Provider<CloudAuthService>((ref) {
  return CloudAuthService(FirebaseAuth.instance);
});

/// Provider that emits auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(cloudAuthProvider).authStateChanges;
});

/// Provider for the currently signed-in user.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(cloudAuthProvider).currentUser;
});

class CloudAuthService {
  final FirebaseAuth _auth;

  CloudAuthService(this._auth);

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register with email and password.
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('The account already exists for that email.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        default:
          return Exception(e.message ?? 'An unknown authentication error occurred.');
      }
    }
    return Exception(e.toString());
  }
}
