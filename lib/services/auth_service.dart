import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use the valid API for google_sign_in as requested
      await GoogleSignIn.instance.initialize(
        serverClientId: '746713602476-l6a8snfcf3kfoblef1398tfsn9bfhbbd.apps.googleusercontent.com',
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      
      // Handle user cancellation safely
      if (googleUser == null) {
        debugPrint('Google Sign-In was cancelled by the user.');
        return null;
      }

      // Obtain the authentication details (idToken)
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential using ONLY idToken as requested
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      // Prevent app crash by catching error safely
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }
}
