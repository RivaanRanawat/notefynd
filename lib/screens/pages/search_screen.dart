import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/pages/profileScreen/user_profile_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot> searchResult;

  searchUser(String typedUser) async {
    var users = FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: typedUser.toLowerCase())
        .limit(20)
        .get();
    setState(() {
      searchResult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      appBar: AppBar(
        leading: Icon(
          Icons.search,
          color: Provider.of<ThemeModel>(context)
              .currentTheme
              .textTheme
              .headline6
              .color,
        ),
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        title: TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: false,
            hintText: "Search",
            hintStyle: GoogleFonts.lato(
                fontSize: 18,
                color: Provider.of<ThemeModel>(context)
                    .currentTheme
                    .textTheme
                    .headline6
                    .color),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: searchUser,
        ),
        automaticallyImplyLeading: false,
      ),
      body: searchResult == null
          ? Center(
              child: Text(
                "Search for users!",
                style: GoogleFonts.raleway(
                  fontSize: 25,
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : FutureBuilder(
              future: searchResult,
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot user = snapshot.data.docs[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => UserProfileScreen(
                              user.data()["uid"],
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(5),
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            backgroundImage:
                                NetworkImage(user.data()["profilePhoto"]),
                          ),
                          title: Text(
                            user.data()["username"],
                            style: TextStyle(
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .headline6
                                    .color,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    });
              }),
    );
  }
}
