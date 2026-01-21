// ignore_for_file: avoid_returning_null_for_void

import 'package:cloture/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      AppLogger.error('Error signing in with email', e);
      return null;
    }
  }

  // Register with email, password, and name
  Future<User?> registerWithEmail(
      String email, String password, String firstName, String lastName) async {
    try {
      // Create the user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // If user is successfully created, set the display name (first + last name)
      if (user != null) {
        await user.updateDisplayName('$firstName $lastName');
        await user.reload(); // Refresh the user data
        user = _auth.currentUser; // Refresh the user instance
      }

      return user;
    } catch (e) {
      AppLogger.error('Error registering with email', e);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      AppLogger.error('Error signing out', e);
      return null;
    }
  }

  // Auth state change listener
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  //method to get current user
  User? get currentUser {
    return _auth.currentUser;
  }
}
