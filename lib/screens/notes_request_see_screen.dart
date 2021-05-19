import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/request_new_notes_screen.dart';
import 'package:notefynd/screens/view_requested_notes_screen.dart';
import 'package:notefynd/universal_variables.dart';

class NotesRequestSeeScreen extends StatefulWidget {
  @override
  _NotesRequestSeeScreenState createState() => _NotesRequestSeeScreenState();
}

class _NotesRequestSeeScreenState extends State<NotesRequestSeeScreen> {
  var isCreator = false;

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
      isCreator = snapshot["status"] == "creator";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: isCreator ? 2 : 1,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: UniversalVariables().primaryColor,
                title: Text('Request Notes'),
                bottom: isCreator
                    ? TabBar(
                        tabs: [
                          Tab(
                              icon: Icon(Icons.add_to_home_screen_rounded),
                              text: "Request"),
                          Tab(
                              icon: Icon(Icons.remove_red_eye_sharp),
                              text: "View")
                        ],
                      )
                    : TabBar(
                        tabs: [
                          Tab(
                              icon: Icon(Icons.add_to_home_screen_rounded),
                              text: "Request"),
                        ],
                      )),
            body: isCreator
                ? TabBarView(
                    children: [
                      RequestNewNotes(),
                      ViewRequestedNotesScreen(),
                    ],
                  )
                : TabBarView(
                    children: [
                      RequestNewNotes(),
                    ],
                  )),
      ),
    );
  }
}
