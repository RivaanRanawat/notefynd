import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/add_pdf_notes.dart';
import 'package:notefynd/screens/auth/details_screen.dart';
import 'package:notefynd/screens/pages/notes_screen.dart';
import 'package:notefynd/screens/pages/profile_screen.dart';
import 'package:notefynd/screens/pages/videos_screen.dart';
import 'package:notefynd/services/Creator.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UniversalVariables universalVariables = UniversalVariables();
  int pageIndex = 0;

  String status;

  getUserStatus() async {
    String tempStatus = await Provider.of<Creator>(context).getCreatorStatus();
    setState(() {
      status = tempStatus;
    });
  }

  List pageOptions = [
    VideoScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];
  List creatorPageOptions = [
    VideoScreen(),
    NotesScreen(),
    AddPdfNotes(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserStatus();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    String bio;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    bio = snapshot["bio"];
    if (bio == "") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => DetailsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalVariables.secondaryColor,
      body: status == "creator"
          ? creatorPageOptions[pageIndex]
          : pageOptions[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (newIdx) {
          setState(() {
            pageIndex = newIdx;
          });
        },
        backgroundColor: universalVariables.secondaryColor,
        unselectedItemColor: Colors.white,
        currentIndex: pageIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.video_collection, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf, size: 30), label: ""),
          if (status == "creator")
            BottomNavigationBarItem(icon: Icon(Icons.add, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), label: ""),
        ],
      ),
    );
  }
}
