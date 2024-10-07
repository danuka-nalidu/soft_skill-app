import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  //for storing data in cloud firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

//For signup
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String name}) async {
    String res = " Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //Register user in firebase auth
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        //Adding user to cloud firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          "name": name,
          "email": email,
          "uid": credential.user!.uid,
          //cant store password in cloud firestore
        });
        res = "success";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //For login scree
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //Login user in firebase auth email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter eall the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  //For logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
