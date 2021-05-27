import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Creator with ChangeNotifier {
  String status;
  Creator() {
    getCreatorsStatus();
  }

  String getStatus() => status;

  getCreatorsStatus() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    status = snapshot["status"];
    notifyListeners();
  }

  updateToCreatorStatus() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({"status": "creator"});
    status = "creator";
    notifyListeners();
  }
}
