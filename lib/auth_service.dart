import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Login - Modified to handle missing profile gracefully
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;
      if (user == null) {
        throw Exception("Login failed. Please try again.");
      }

      // Check if Firestore profile exists, but don't sign out if it doesn't
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Instead of signing out, we'll create a basic profile
        await _createBasicProfile(user, email);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } on Exception catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  // Helper method to create a basic profile if it doesn't exist
  Future<void> _createBasicProfile(User user, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        "name": user.displayName ?? "User",
        "age": 0,
        "gender": "Not specified",
        "medicalHistory": "",
        "allergies": [],
        "email": email.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating basic profile: $e");
      // Don't throw here, we don't want to block login
    }
  }

  // ✅ Register (creates Auth user + Firestore profile)
  Future<User?> registerWithEmailAndPassword(
      String email, String password, UserProfile profile) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "name": profile.name,
          "age": profile.age,
          "gender": profile.gender,
          "medicalHistory": profile.medicalHistory,
          "allergies": profile.allergies,
          "email": email.trim(),
          "createdAt": FieldValue.serverTimestamp(),
        });

        return user;
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ Fetch profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  // ✅ Update profile
  Future<bool> updateUserProfile(String uid, UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(uid).update(profile.toMap());
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }
}