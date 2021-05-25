import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../comment_screen.dart';

class CreatorStudioScreen extends StatefulWidget {
  @override
  _CreatorStudioScreenState createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> {
  String followers;
  String postsNo;
  Future topPosts;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    var posts = await FirebaseFirestore.instance
        .collection("pdf-posts")
        .where("uid", isEqualTo: uid)
        .get();
    postsNo = posts.docs.length.toString();
    var userFollowerDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("followers")
        .get();
    if (userFollowerDoc.docs.length > 0) {
      followers = userFollowerDoc.docs.length.toString();
    } else if (userFollowerDoc.docs.length > 999) {
      int noOfFollowers = (userFollowerDoc.docs.length / 1000) as int;
      followers = noOfFollowers.toString();
    }
    print(followers);
    print(postsNo);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        title: Text(
          "Creator Studio",
          style:
              Provider.of<ThemeModel>(context).currentTheme.textTheme.headline6,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 16,
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .primaryColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30, top: 20, bottom: 10),
                                child: Text(
                                  postsNo != null ? postsNo : "0",
                                  style: TextStyle(
                                    color: Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .textTheme
                                        .headline6
                                        .color,
                                    fontSize: 70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "Posts",
                                  style: TextStyle(
                                      color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 16,
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .primaryColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30, top: 20, bottom: 10),
                                child: Text(
                                  followers != null ? followers : "0",
                                  style: TextStyle(
                                    color: Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .textTheme
                                        .headline6
                                        .color,
                                    fontSize: 70,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "Followers",
                                  style: TextStyle(
                                      color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .subtitle2
                                          .color,
                                      fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Recent Posts: ",
                      style: GoogleFonts.lato(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 18),
                    ),
                  ),
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("pdf-posts")
                        .where("uid",
                            isEqualTo: FirebaseAuth.instance.currentUser.uid)
                        .orderBy("datePublished", descending: true)
                        .limit(5)
                        .get(),
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot posts = snapshot.data.docs[index];
                          Timestamp timestamp = posts.data()["datePublished"];
                          DateTime dateTime = timestamp.toDate();
                          String timePosted = timeago.format(dateTime);
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Provider.of<ThemeModel>(context)
                                  .currentTheme
                                  .primaryColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Wrap(
                                        direction: Axis.vertical,
                                        children: [
                                          Text(
                                            posts.data()["title"],
                                            style: GoogleFonts.lato(
                                              color: Provider.of<ThemeModel>(
                                                      context)
                                                  .currentTheme
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(timePosted,
                                              style: GoogleFonts.lato(
                                                color: Provider.of<ThemeModel>(
                                                        context)
                                                    .currentTheme
                                                    .textTheme
                                                    .subtitle2
                                                    .color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              textAlign: TextAlign.left),
                                        ],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            "Grade : " + posts.data()["grade"],
                                            style: GoogleFonts.lato(
                                              color: Provider.of<ThemeModel>(
                                                      context)
                                                  .currentTheme
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            "Notes for " +
                                                posts.data()["subject"] +
                                                " , " +
                                                posts.data()["stream"],
                                            style: GoogleFonts.lato(
                                                color: Provider.of<ThemeModel>(
                                                        context)
                                                    .currentTheme
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            "Description: " +
                                                posts.data()["description"],
                                            style: GoogleFonts.lato(
                                                color: Provider.of<ThemeModel>(
                                                        context)
                                                    .currentTheme
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data.docs.length,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
