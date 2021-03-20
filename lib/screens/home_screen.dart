import "package:flutter/material.dart";
import 'package:notefynd/screens/pages/notes_screen.dart';
import 'package:notefynd/screens/pages/profile_screen.dart';
import 'package:notefynd/screens/pages/videos_screen.dart';
import 'package:notefynd/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UniversalVariables universalVariables = UniversalVariables();
  List pageOptions = [
    VideoScreen(),
    NotesScreen(),
    ProfileScreen()
  ];

  int pageIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalVariables.secondaryColor,
      body: pageOptions[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf, size: 30), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: ""),
        ],
      ),
    );
  }
}
