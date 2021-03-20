import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthMethods with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> signUpUser(String email, String password, String username) async {
    String returnValue = "error";
    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    _firestore.collection("users").doc(_credential.user.uid).set({
      "username": username.trim(),
      "email": email.trim(),
      "password": password.trim(),
      "status": "user",
    });
    returnValue = "success";
    } catch(err) {
      returnValue = err.toString();
    }
    return returnValue;
  }
}
