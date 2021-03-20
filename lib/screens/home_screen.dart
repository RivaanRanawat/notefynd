import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/pages/notes_screen.dart';
import 'package:notefynd/screens/pages/profile_screen.dart';
import 'package:notefynd/screens/pages/videos_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
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

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: universalVariables.secondaryColor,
      // body: Center(
      //   child: ElevatedButton(
      //     onPressed: () async {
      //       String result = await AuthMethods().signOut();
      //       if (result == "success") {
      //         Navigator.of(context).pushReplacement(
      //             MaterialPageRoute(builder: (ctx) => LoginScreen()));
      //       }
      //     },
      //     child: Text("Log out"),
      //   ),
      // ),
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
