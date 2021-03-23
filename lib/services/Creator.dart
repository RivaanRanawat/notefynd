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

  Future<String> storePdfNotes(File _file, String _fileName, String standard,
      String _title, String subject, String description, String stream) async {
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
      FirebaseFirestore.instance
          .collection("pdf-posts")
          .doc(standard)
          .collection(FirebaseAuth.instance.currentUser.uid)
          .doc(_title)
          .set({
        "uid": FirebaseAuth.instance.currentUser.uid,
        "datePublished": DateTime.now().toString(),
        "pdfUrl": url,
        "title": _title,
        "standard": standard,
        "description": description,
        "subject": subject,
        "stream": stream,
        "likes": [],
        "comments": [],
        "reports": [],
      });
      retValue = "success";
    } catch (err) {
      retValue = err;
    }
    return retValue;
  }
}
