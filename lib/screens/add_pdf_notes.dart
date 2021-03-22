import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import "package:flutter/material.dart";
import 'dart:io';

import 'package:notefynd/universal_variables.dart';

class AddPdfNotes extends StatefulWidget {
  @override
  _AddPdfNotesState createState() => _AddPdfNotesState();
}

class _AddPdfNotesState extends State<AddPdfNotes> {
  File _file;
  String fileName;
  TextEditingController _titleController = TextEditingController();
  var _isLoading = false;
  String subject = "Maths";
  String standard = "10";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: _isLoading == false
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  _file != null
                      ? Center(child: Text(fileName))
                      : Text(
                          "",
                          style: TextStyle(color: Colors.white),
                        ),
                  Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          File file = File(result.files.single.path);

                          setState(() {
                            _file = file;
                            fileName = result.files.single.name;
                          });
                        } else {
                          print("in sooth ik not why i am so sad");
                        }
                      },
                      child: Text(
                        "Select PDF",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: UniversalVariables().secondaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Title",
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  MaterialButton(
                    minWidth: 150,
                    elevation: 0,
                    height: 50,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        if (_titleController.text.isNotEmpty && _file != null) {
                          var reference = firebase_storage
                              .FirebaseStorage.instance
                              .ref()
                              .child("pdf-notes")
                              .child(FirebaseAuth.instance.currentUser.uid)
                              .child(fileName);

                          firebase_storage.UploadTask uploadTask =
                              reference.putFile(
                                  _file,
                                  firebase_storage.SettableMetadata(
                                      contentType:
                                          ContentType('application', 'pdf')
                                              .toString()));
                          firebase_storage.TaskSnapshot snapshot =
                              await uploadTask;
                          String url = await snapshot.ref.getDownloadURL();
                          print("epic " + url);
                          FirebaseFirestore.instance
                              .collection("pdf-posts")
                              .doc(standard)
                              .collection(FirebaseAuth.instance.currentUser.uid)
                              .doc(_titleController.text)
                              .set({
                            "uid": FirebaseAuth.instance.currentUser.uid,
                            "datePublished": DateTime.now().toString(),
                            "pdfUrl": url,
                            "title": _titleController.text,
                            "standard": standard,
                            "subject": subject,
                            "likes": [],
                            "comments": [],
                            "reports": [],
                          });
                          setState(() {
                            _isLoading = false;
                          });
                          setState(() {
                            _titleController.text = "";
                            _file = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Posted!"),
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Enter title and image"),
                          ));
                        }
                      } catch (err) {
                        print(err);
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    color: UniversalVariables().logoGreen,
                    child: Text("Share"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    textColor: Colors.white,
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
