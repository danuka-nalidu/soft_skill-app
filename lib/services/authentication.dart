import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // For storing data in cloud firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // For authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // For signup
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String role, // Accept role as a parameter
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // Register user in firebase auth
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Adding user to cloud firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          "name": name,
          "email": email,
          "uid": credential.user!.uid,
          "role": role, // Save the selected role in Firestore
        });
        res = "success";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  // For login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Login user in firebase auth email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // Fetch user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      return doc.data() as Map<String, dynamic>?; // Return user data
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // For logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
