import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/Creator.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

class AddPdfNotes extends StatefulWidget {
  @override
  _AddPdfNotesState createState() => _AddPdfNotesState();
}

class _AddPdfNotesState extends State<AddPdfNotes> {
  File _file;
  Uint8List _fileForWeb;
  String fileName;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _videoUrlController = TextEditingController();

  var _isLoading = false;
  String _grade = "";

  handleClassButtonClick(String grade) {
    setState(() {
      _grade = grade;
    });
    print(_grade);
  }

  uploadPdftoFirebase() async {
    setState(() {
      _isLoading = true;
    });
    if (_titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _subjectController.text.isNotEmpty &&
            _grade.isNotEmpty &&
            _file != null ||
        _fileForWeb != null) {
      try {
        var reference = FirebaseStorage.instance
            .ref()
            .child("pdf-notes")
            .child(FirebaseAuth.instance.currentUser.uid)
            .child(fileName);
        UploadTask uploadTask;
        if (!kIsWeb) {
          uploadTask = reference.putFile(
              _file,
              SettableMetadata(
                  contentType: ContentType('application', 'pdf').toString()));
        } else {
          uploadTask = reference.putData(
              _fileForWeb,
              SettableMetadata(
                  contentType: ContentType('application', 'pdf').toString()));
        }
        TaskSnapshot snapshot = await uploadTask;
        String url = await snapshot.ref.getDownloadURL();
        DocumentSnapshot snap = await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get();
        var username = snap["username"];
        var uniqueId = Uuid().v1();
        var videoUrl = "";
        if (_videoUrlController.text.isNotEmpty) {
          var isValidUrl = isURL(_videoUrlController.text);
          if(isValidUrl) {
            videoUrl = _videoUrlController.text;
          } else {
            setState(() {
              _isLoading = false;
            });
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid url."),));
          }
        }
        FirebaseFirestore.instance.collection("pdf-posts").doc(uniqueId).set({
          "uid": FirebaseAuth.instance.currentUser.uid,
          "datePublished": Timestamp.now(),
          "pdfUrl": url,
          "title": _titleController.text,
          "grade": _grade.toString(),
          "description": _descriptionController.text,
          "subject": _subjectController.text,
          "username": username,
          "likes": [],
          "commentCount": 0,
          "reports": [],
          "videoUrl": videoUrl,
          "stream": snap["stream"],
          "profilePic": snap["profilePhoto"],
          "id": uniqueId
        });

        setState(() {
          _titleController.text = "";
          _descriptionController.text = "";
          _subjectController.text = "";
          _file = null;
          _isLoading = false;
          _videoUrlController.text = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Posted!"),
          duration: Duration(seconds: 2),
        ));
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Enter all the fields"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      body: _isLoading == false
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  _file != null
                      ? Center(
                          child: Text(
                          fileName,
                          style: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6,
                        ))
                      : Text(
                          "",
                          style: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6,
                        ),
                  Center(
                    child: MaterialButton(
                      color: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .accentColor,
                      onPressed: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          if (kIsWeb) {
                            Uint8List uploadfile = result.files.single.bytes;
                            setState(() {
                              _fileForWeb = uploadfile;
                              fileName = result.files.single.name;
                            });
                          } else {
                            File file = File(result.files.single.path);

                            setState(() {
                              _file = file;
                              fileName = result.files.single.name;
                            });
                          }
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
                        color: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .primaryColor,
                        border: Border.all(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .accentColor)),
                    child: TextFormField(
                      controller: _titleController,
                      style: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Title",
                        labelStyle: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .primaryColor,
                        border: Border.all(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .accentColor)),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Description",
                        labelStyle: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .primaryColor,
                        border: Border.all(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .accentColor)),
                    child: TextFormField(
                      controller: _subjectController,
                      style: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Subject",
                        labelStyle: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .primaryColor,
                        border: Border.all(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .accentColor)),
                    child: TextFormField(
                      controller: _videoUrlController,
                      style: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Video URL(Optional)",
                        labelStyle: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 19.0, right: 19.0, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Class",
                            style: GoogleFonts.lato(
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .headline6
                                    .color,
                                fontSize: 14)),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("7"),
                                color: _grade == "7"
                                    ? Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .accentColor
                                    : Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .buttonColor,
                                child: Text("7"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("8"),
                                color: _grade == "8"
                                    ? Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .accentColor
                                    : Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .buttonColor,
                                child: Text("8"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("9"),
                                color: _grade == "9"
                                    ? Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .accentColor
                                    : Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .buttonColor,
                                child: Text("9"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("10"),
                                color: _grade == "10"
                                    ? Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .accentColor
                                    : Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .buttonColor,
                                child: Text("10"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("11"),
                                  color: _grade == "11"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      : Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("11"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("12"),
                                  color: _grade == "12"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      : Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("12"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("UG"),
                                  color: _grade == "UG"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      : Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("UG"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("PG"),
                                  color: _grade == "PG"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      : Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("PG"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  MaterialButton(
                    minWidth: 150,
                    elevation: 0,
                    height: 50,
                    onPressed: uploadPdftoFirebase,
                    color: Provider.of<ThemeModel>(context)
                        .currentTheme
                        .accentColor,
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
