import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // STATUS -> user, creator, admin

  // SIGN UP
  Future<String> signUpUser(
      String email, String password, String username) async {
    String returnValue = "error";
    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      _firestore.collection("users").doc(_credential.user.uid).set({
        "username": username.contains(" ")
            ? username.replaceAll(" ", "").toLowerCase().trim()
            : username.toLowerCase().trim(),
        "email": email.trim(),
        "status": "user",
        "bio": "",
        "profilePhoto": "",
        "schoolName": "",
        "stream": "",
        "subject": "",
        "grade": "",
        "uid": _credential.user.uid,
      });
      returnValue = "success";
    } catch (err) {
      returnValue = err.toString();
    }
    return returnValue;
  }

  Future<String> loginWithEmailAndPassword(
      String email, String password) async {
    String returnValue = "error";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      returnValue = "success";
    } catch (err) {
      returnValue = err.toString();
    }
    return returnValue;
  }

  Future<String> loginUserWithGoogle() async {
    String retVal = "error";
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User user = userCredential.user;
      QuerySnapshot snap =
          await FirebaseFirestore.instance.collection("users").get();

      int ctr = 0;
      snap.docs.map((e) {
        // user signing up
        if (user.uid == e.data()["uid"]) {
          return;
        } 
          ctr+=1;
      }).toList();
      print(snap.docs.length);
      if (ctr == snap.docs.length) {
        _firestore.collection("users").doc(user.uid).set({
          "username": user.email.split("@")[0],
          "email": user.email,
          "status": "user",
          "bio": "",
          "profilePhoto": user.photoURL,
          "schoolName": "",
          "stream": "",
          "subject": "",
          "grade": "",
          "uid": user.uid,
        });
      retVal = "signup";
      } else {
        retVal = "login";
      }
    } catch (err) {
      retVal = err.toString();
    }
    return retVal;
  }

  Future<String> signOut() async {
    String retVal = "error";

    try {
      await _auth.signOut();
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
