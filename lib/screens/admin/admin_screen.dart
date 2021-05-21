import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/pages/articles/board_articles.dart';
import 'package:notefynd/screens/admin/notes_management.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/universal_variables.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    var items = [
      NotesManagement(),
      BoardArticles(),
      AlertDialog(
        title: Text("Log Out Confirmation"),
        content: Text(
          "Are you sure you want to log out from this account?",
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => LoginScreen()));
            },
            child: Text(
              "Confirm",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => AdminScreen()));
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: items[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: UniversalVariables().secondaryColor,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.article,
                color: Colors.white,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: ""),
        ],
      ),
    );
  }
}
