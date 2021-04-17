import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/add_content.dart';
import 'package:notefynd/screens/admin/admin_add_article.dart';
import 'package:notefynd/screens/admin/board_articles.dart';
import 'package:notefynd/screens/admin_screen.dart';
import 'package:notefynd/screens/auth/details_screen.dart';
import 'package:notefynd/screens/pages/notes_screen.dart';
import 'package:notefynd/screens/pages/profile_screen.dart';
import 'package:notefynd/screens/pages/search_screen.dart';
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
    // VideoScreen(),
    NotesScreen(),
    SearchScreen(),
    BoardArticles(),
    ProfileScreen(),
  ];
  List creatorPageOptions = [
    // VideoScreen(),
    NotesScreen(),
    SearchScreen(),
    AddContent(),
    BoardArticles(),
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
    String status;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    bio = snapshot["bio"];
    status = snapshot["status"];
    if (bio == "") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => DetailsScreen()));
    }

    if(status == "admin") {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => AdminScreen()));
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
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.video_collection, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30), label: ""),
          if (status == "creator")
            BottomNavigationBarItem(icon: customIcon(), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.article, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), label: ""),
        ],
      ),
    );
  }

  customIcon() {
    return Container(
      width: 45.0,
      height: 30.0,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.0),
            width: 38,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 250, 45, 108),
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10.0),
            width: 38,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 32, 211, 234),
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
          Center(
            child: Container(
              height: double.infinity,
              width: 38,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7.0)),
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
