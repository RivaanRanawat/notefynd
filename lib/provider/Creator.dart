import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import "dart:io";
import "package:firebase_storage/firebase_storage.dart" as firebase_storage;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Creator with ChangeNotifier {
  Future<String> getCreatorStatus() async {
    String creator;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    creator = snapshot["status"];
    notifyListeners();
    return creator;
  }

  
}
