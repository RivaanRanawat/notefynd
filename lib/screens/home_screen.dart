import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/pages/creator/add_content.dart';
import 'package:notefynd/screens/pages/articles/board_articles.dart';
import 'package:notefynd/screens/admin/admin_screen.dart';
import 'package:notefynd/screens/auth/details_screen.dart';
import 'package:notefynd/screens/pages/pdfs/notes_screen.dart';
import 'package:notefynd/screens/pages/profileScreen/profile_screen.dart';
import 'package:notefynd/screens/pages/search_screen.dart';
import 'package:notefynd/provider/Creator.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UniversalVariables universalVariables = UniversalVariables();
  int pageIndex = 0;
  PageController _pageController;

  List<Widget> pageOptions = [
    // VideoScreen(),
    NotesScreen(),
    SearchScreen(),
    BoardArticles(),
    ProfileScreen(),
  ];
  List<Widget> creatorPageOptions = [
    // VideoScreen(),
    NotesScreen(),
    SearchScreen(),
    AddContent(),
    BoardArticles(),
    ProfileScreen(),
  ];
  @override
  void initState() {
    super.initState();
    getUserData();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.bottomToTop, child: DetailsScreen()));
    }

    if (status == "admin") {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => AdminScreen()));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      pageIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = Provider.of<Creator>(context).getStatus();
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => pageIndex = index);
          },
          children: status == "creator" ? creatorPageOptions : pageOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        selectedItemColor: Provider.of<ThemeModel>(context)
                        .currentTheme
                        .accentColor,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
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
