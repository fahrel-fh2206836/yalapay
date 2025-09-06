import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Create user with email and password
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Update the user's display name with first and last name
    await userCredential.user?.updateDisplayName('$firstName $lastName');
    await userCredential.user?.reload(); // Ensure updated data is loaded
  }

  Future<void> signin({required String email, required String password}) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
  }
}
