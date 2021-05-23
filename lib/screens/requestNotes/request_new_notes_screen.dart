import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RequestNewNotes extends StatefulWidget {
  @override
  _RequestNewNotesState createState() => _RequestNewNotesState();
}

class _RequestNewNotesState extends State<RequestNewNotes> {
  TextEditingController _topicNameController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  var _universalVariables = UniversalVariables();
  String _grade = "";

  handleClassButtonClick(String grade) {
    setState(() {
      _grade = grade;
    });
    print(_grade);
  }

  requestNotes() async {
    if (_subjectController.text.isNotEmpty &&
        _topicNameController.text.isNotEmpty &&
        _grade.isNotEmpty) {
      var uniqueId = Uuid().v1();
      await FirebaseFirestore.instance
          .collection("postRequests")
          .doc(uniqueId)
          .set({
        "requestID": uniqueId,
        "topic": _topicNameController.text,
        "grade": _grade,
        "subject": _subjectController.text,
        "uid": FirebaseAuth.instance.currentUser.uid,
        "datePublished": Timestamp.now(),
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Thank You For Your Request! You will be provided with the notes soon!"),
      ));
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
              child: HomeScreen(), type: PageTransitionType.rightToLeft),
          (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter all the fields"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Provider.of<ThemeModel>(context)
                        .currentTheme
                        .primaryColor,
                    border: Border.all(color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .accentColor)),
                child: TextFormField(
                  controller: _topicNameController,
                  style: TextStyle(
                      color: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6
                          .color),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: "Topic Name",
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
                    border: Border.all(color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .accentColor)),
                child: TextFormField(
                  controller: _subjectController,
                  style: TextStyle(
                      color: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6
                          .color),
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
              Padding(
                padding:
                    const EdgeInsets.only(left: 19.0, right: 19.0, bottom: 15),
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
                            minWidth: MediaQuery.of(context).size.width * 0.20,
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
                            minWidth: MediaQuery.of(context).size.width * 0.20,
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
                            minWidth: MediaQuery.of(context).size.width * 0.20,
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
                            minWidth: MediaQuery.of(context).size.width * 0.20,
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
              MaterialButton(
                minWidth: 150,
                elevation: 0,
                height: 50,
                onPressed: requestNotes,
                color:
                    Provider.of<ThemeModel>(context).currentTheme.accentColor,
                child: Text("Done"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                textColor: Colors.white,
              ),
            ],
          ),
        ));
  }
}
