import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import "dart:io";
import "package:firebase_storage/firebase_storage.dart" as firebase_storage;

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

  Future<String> storePdfNotes(File _file, String _fileName, String _title,
      String subject, String description, String school) async {
    String retValue = "";
    try {
      var reference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("pdf-notes")
          .child(FirebaseAuth.instance.currentUser.uid)
          .child(_fileName);

      firebase_storage.UploadTask uploadTask = reference.putFile(
          _file,
          firebase_storage.SettableMetadata(
              contentType: ContentType('application', 'pdf').toString()));
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      print("epic " + url);
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();
      var username = snap["username"];
      FirebaseFirestore.instance.collection("pdf-posts").add({
        "uid": FirebaseAuth.instance.currentUser.uid,
        "datePublished": Timestamp.now(),
        "pdfUrl": url,
        "title": _title,
        "grade": snap["grade"],
        "description": description,
        "subject": subject,
        "username": username,
        "schoolName": school,
        "likes": [],
        "comments": [],
        "reports": [],
        "stream": snap["stream"],
        "profilePic": snap["profilePhoto"]
      });
      retValue = "success";
    } catch (err) {
      retValue = err;
    }
    return retValue;
  }
}
