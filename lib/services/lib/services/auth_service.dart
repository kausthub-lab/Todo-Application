import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
