import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/universal_variables.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot> searchResult;

  searchUser(String typedUser) {
    var users = FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: typedUser)
        .get();
    setState(() {
      searchResult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      appBar: AppBar(
        backgroundColor: UniversalVariables().secondaryColor,
        title: TextFormField(
          decoration: InputDecoration(
            filled: false,
            hintText: "Search",
            hintStyle: GoogleFonts.lato(fontSize: 18, color: Colors.white),
          ),
          onFieldSubmitted: searchUser,
        ),
      ),
      body: searchResult == null
          ? Center(
              child: Text(
                "Search for users!",
                style: GoogleFonts.raleway(
                  fontSize: 25,
                  color: Colors.white,
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
                        // onTap: () => Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (ctx) => ProfilePage(
                        //       user.data()["uid"],
                        //     ),
                        //   ),
                        // ),
                        onTap: () {},
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            backgroundImage:
                                NetworkImage(user.data()["profilePhoto"]),
                          ),
                          trailing: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          title: Text(
                            user.data()["username"],
                            style: GoogleFonts.lato(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                      );
                    });
              }),
    );
  }
}
