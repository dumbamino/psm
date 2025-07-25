// lib/service/auth.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This is your PRIMARY sign-in method
  Future<User?> signInWithFullNameAndPassword({
    required String fullName, // This parameter directly corresponds to what the user types in the "Username" field
    required String password,
  }) async {
    print("AuthService: Attempting login with fullName (acting as username): $fullName");
    try {
      // Step 1: Query Firestore to get the email associated with the fullName
      final querySnapshot = await _firestore
          .collection('users') // Make sure 'users' is your correct collection name
          .where('fullName', isEqualTo: fullName) // Querying by the exact fullName string
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('AuthService: No user found with fullName "$fullName" in Firestore.');
        // This error means the "Username" (which is a fullName) entered doesn't exist in your database
        throw Exception('Username not found. Please check your username or register.');
      }

      final userDoc = querySnapshot.docs.first;
      final email = userDoc['email'] as String?;

      if (email == null || email.isEmpty) {
        print('AuthService: Email not found or empty for user with fullName "$fullName" in Firestore.');
        throw Exception('User data is incomplete for this username. Unable to log in.');
      }
      print('AuthService: Found email "$email" for fullName "$fullName".');

      // Step 2: Sign in with Firebase Auth using the retrieved email and provided password
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("AuthService: Firebase signInWithEmailAndPassword successful. User UID: ${userCredential.user?.uid}");
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during sign in: ${e.code} - ${e.message}");
      // These errors typically mean the password was wrong for the found email, or the email (though found) is malformed for Firebase.
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') { // 'invalid-credential' for wrong password for the email
        throw Exception('Incorrect password for the given username.');
      } else if (e.code == 'user-not-found'){
        // This can happen if the email retrieved from firestore for some reason isn't a valid firebase auth user.
        // This is less likely if your registration process creates both.
        print('AuthService: Email $email found in Firestore but not in Firebase Auth.');
        throw Exception('User account issue. Please contact support.');
      } else if (e.code == 'invalid-email') {
        print('AuthService: Email $email found in Firestore is considered invalid by Firebase Auth.');
        throw Exception('User account email format issue. Please contact support.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many login attempts. Please try again later.');
      }
      throw Exception('Login failed due to an authentication error: ${e.message}'); // Fallback Firebase Auth error
    } catch (e) {
      print("AuthService: Generic exception during sign in: $e");
      if (e is Exception) {
        throw e; // Rethrow specific exceptions (like "Username not found")
      }
      throw Exception('An unexpected error occurred during login. Please try again.');
    }
  }

  // This method was your signInWithUsernameAndPassword.
  // If it's not used, you can remove it.
  // If it IS used and "username" there also means "fullName", it can delegate.
  Future<User?> signInWithUsernameAndPassword({
    required String username, // If this 'username' is actually a 'fullName'
    required String password,
  }) async {
    print("AuthService: signInWithUsernameAndPassword called, delegating to signInWithFullNameAndPassword with username as fullName.");
    // Assuming 'username' parameter here is intended to be the 'fullName'
    return signInWithFullNameAndPassword(fullName: username, password: password);
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print("AuthService: Attempting login with email: $email");
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("AuthService: signInWithEmailAndPassword successful. User UID: ${userCredential.user?.uid}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("AuthService: FirebaseAuthException during email sign in: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found') {
        throw Exception('No account found for that email.');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Incorrect password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many login attempts. Please try again later.');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      print("AuthService: Generic exception during email sign in: $e");
      if (e is Exception) {
        throw e;
      }
      throw Exception('An unexpected error occurred during login. Please try again.');
    }
  }


  Future<void> signOut() async {
    print("AuthService: Signing out user.");
    await _firebaseAuth.signOut();
    print("AuthService: User signed out.");
  }

  User? get currentUser => _firebaseAuth.currentUser;

  get email => null;

  Future<void> signInWithGoogle(BuildContext context) async {}
}