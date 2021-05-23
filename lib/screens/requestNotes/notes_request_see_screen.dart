import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/requestNotes/request_new_notes_screen.dart';
import 'package:notefynd/screens/requestNotes/view_requested_notes_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

class NotesRequestSeeScreen extends StatefulWidget {
  @override
  _NotesRequestSeeScreenState createState() => _NotesRequestSeeScreenState();
}

class _NotesRequestSeeScreenState extends State<NotesRequestSeeScreen> {
  var status = "";

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() async {
    var uid = FirebaseAuth.instance.currentUser.uid;
    var snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    setState(() {
      status = snapshot["status"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: status == "creator" ? 2 : 1,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Provider.of<ThemeModel>(context)
                    .currentTheme
                    .backgroundColor,
                title: Text(
                  'Request Notes',
                  style: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6,
                ),
                bottom: status == "creator"
                    ? TabBar(
                      indicatorColor: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .accentColor,
                        labelColor: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .textTheme
                            .headline6
                            .color,
                        tabs: [
                          Tab(
                              icon: Icon(Icons.add_to_home_screen_rounded,
                                  color: Provider.of<ThemeModel>(context)
                                      .currentTheme
                                      .textTheme
                                      .headline6
                                      .color),
                              text: "Request"),
                          Tab(
                              icon: Icon(
                                Icons.remove_red_eye_sharp,
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .headline6
                                    .color,
                              ),
                              text: "View")
                        ],
                      )
                    : status == "user"
                        ? TabBar(
                            tabs: [
                              Tab(
                                  icon: Icon(Icons.add_to_home_screen_rounded,
                                      color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .headline6
                                          .color),
                                  text: "Request"),
                            ],
                          )
                        : TabBar(
                            tabs: [
                              Tab(
                                  icon: Icon(Icons.remove_red_eye_sharp,
                                      color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .headline6
                                          .color),
                                  text: "View"),
                            ],
                          )),
            body: status == "creator"
                ? TabBarView(
                    children: [
                      RequestNewNotes(),
                      ViewRequestedNotesScreen(status: status),
                    ],
                  )
                : status == "user"
                    ? TabBarView(
                        children: [
                          RequestNewNotes(),
                        ],
                      )
                    : TabBarView(
                        children: [
                          ViewRequestedNotesScreen(status: status),
                        ],
                      )),
      ),
    );
  }
}
