import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/admin/admin_add_article.dart';
import 'package:notefynd/screens/pages/articles/detail_article.dart';
import 'package:notefynd/screens/comment_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import "package:timeago/timeago.dart" as tago;

class BoardArticles extends StatefulWidget {
  @override
  _BoardArticlesState createState() => _BoardArticlesState();
}

class _BoardArticlesState extends State<BoardArticles> {
  String status;
  String postsNo;
  String usersNo;
  @override
  void initState() {
    super.initState();
    getUserStatus();
  }

  getUserStatus() async {
    QuerySnapshot userSnap =
        await FirebaseFirestore.instance.collection("users").get();
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    var posts = await FirebaseFirestore.instance.collection("pdf-posts").get();
    setState(() {
      status = snap["status"];
      postsNo = posts.docs.length.toString();
      usersNo = userSnap.docs.length.toString();
    });
    print(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        title: Text(
          "Articles",
          style:
              Provider.of<ThemeModel>(context).currentTheme.textTheme.headline6,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("articles")
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              status == "admin" && status != null
                  ? Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        left: 30.0,
                                        right: 30,
                                        top: 20,
                                        bottom: 10),
                                    child: Text(
                                      postsNo != null ? postsNo : "0",
                                      style: TextStyle(
                                        color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .headline6
                                            .color,
                                        fontSize: 65,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      "Posts",
                                      style: TextStyle(
                                          color:
                                              Provider.of<ThemeModel>(context)
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
                                        left: 30.0,
                                        right: 30,
                                        top: 20,
                                        bottom: 10),
                                    child: Text(
                                      usersNo != null ? usersNo : "0",
                                      style: TextStyle(
                                        color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .headline6
                                            .color,
                                        fontSize: 65,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      "Users",
                                      style: TextStyle(
                                          color:
                                              Provider.of<ThemeModel>(context)
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
                    )
                  : Container(),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (ctx, idx) {
                    var posts = snapshot.data.docs[idx];
                    Timestamp timestamp = posts.data()["datePublished"];
                    DateTime dateTime = timestamp.toDate();
                    String timePosted = tago.format(dateTime);

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: DetailArticle(
                              content: posts.data()["content"],
                              title: posts.data()["title"],
                              timePublished: timePosted,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .primaryColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                trailing: status == "admin" && status != null
                                    ? PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert,
                                            color:
                                                Provider.of<ThemeModel>(context)
                                                    .currentTheme
                                                    .textTheme
                                                    .headline6
                                                    .color),
                                        onSelected: (String choice) {
                                          if (choice == "Delete") {
                                            return showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    Text("Delete Confirmation"),
                                                content: Text(
                                                  "Are you sure you want to delete Your PDF?",
                                                  style: GoogleFonts.lato(),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "articles")
                                                          .doc(posts
                                                              .data()["id"])
                                                          .delete();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      "Confirm",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Cancel"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ["Delete"]
                                              .map((String choice) {
                                            return PopupMenuItem<String>(
                                              value: choice,
                                              child: Text(
                                                choice,
                                                style: Provider.of<ThemeModel>(
                                                        context)
                                                    .currentTheme
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            );
                                          }).toList();
                                        })
                                    : Text(""),
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        posts.data()["title"],
                                        style: GoogleFonts.lato(
                                          color:
                                              Provider.of<ThemeModel>(context)
                                                  .currentTheme
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timePosted,
                                      style: GoogleFonts.lato(
                                        color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .subtitle2
                                            .color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    status != "admin" && status != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  if (posts
                                                      .data()["likes"]
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .uid)) {
                                                    FirebaseFirestore.instance
                                                        .collection("articles")
                                                        .doc(posts.data()["id"])
                                                        .update({
                                                      "likes": FieldValue
                                                          .arrayRemove([
                                                        FirebaseAuth.instance
                                                            .currentUser.uid
                                                      ]),
                                                    });
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection("articles")
                                                        .doc(posts.data()["id"])
                                                        .update({
                                                      "likes": FieldValue
                                                          .arrayUnion([
                                                        FirebaseAuth.instance
                                                            .currentUser.uid
                                                      ]),
                                                    });
                                                  }
                                                },
                                                icon: posts
                                                        .data()["likes"]
                                                        .contains(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            .uid)
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                        size: 25,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border,
                                                        color: Provider.of<
                                                                    ThemeModel>(
                                                                context)
                                                            .currentTheme
                                                            .textTheme
                                                            .headline6
                                                            .color,
                                                        size: 25,
                                                      ),
                                              ),
                                              Text(
                                                posts
                                                    .data()["likes"]
                                                    .length
                                                    .toString(),
                                                style: GoogleFonts.lato(
                                                  color:
                                                      Provider.of<ThemeModel>(
                                                              context)
                                                          .currentTheme
                                                          .textTheme
                                                          .headline6
                                                          .color,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.of(context).push(
                                                  PageTransition(
                                                    type: PageTransitionType
                                                        .bottomToTop,
                                                    child: CommentScreen(
                                                        id: posts.data()["id"],
                                                        fileType: "article"),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.comment,
                                                  color:
                                                      Provider.of<ThemeModel>(
                                                              context)
                                                          .currentTheme
                                                          .textTheme
                                                          .headline6
                                                          .color,
                                                  size: 25,
                                                ),
                                              ),
                                              Text(
                                                posts
                                                    .data()["commentCount"]
                                                    .toString(),
                                                style: GoogleFonts.lato(
                                                  color:
                                                      Provider.of<ThemeModel>(
                                                              context)
                                                          .currentTheme
                                                          .textTheme
                                                          .headline6
                                                          .color,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(""),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          );
        },
      ),
      floatingActionButton: status == "admin" && status != null
          ? FloatingActionButton(
              backgroundColor:
                  Provider.of<ThemeModel>(context).currentTheme.accentColor,
              child: Icon(
                Icons.add,
              ),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => AdminAddArticle())),
            )
          : Container(),
    );
  }
}
