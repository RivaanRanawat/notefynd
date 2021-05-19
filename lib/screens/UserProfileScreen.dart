import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/comment_screen.dart';
import 'package:notefynd/universal_variables.dart';
import "package:timeago/timeago.dart" as timeago;
import "dart:async";

class UserProfileScreen extends StatefulWidget {
  final String uid;
  UserProfileScreen(this.uid);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String username;
  String currentUser;
  String profilePic;
  Future myPdf;
  var likes = 0;
  var isFollowing = false;
  var isLiked;
  int following;
  int followers;
  String bio = "";
  String grade = "";
  String schoolName = "";
  String stream = "";
  int noOfPosts = 0;
  var _isLoading = false;
  TextEditingController usernameController = TextEditingController();
  var userCollection = FirebaseFirestore.instance.collection("users");

  followUser() async {
    var doc = await userCollection
        .doc(widget.uid)
        .collection("followers")
        .doc(currentUser)
        .get();
    if (!doc.exists) {
      userCollection
          .doc(widget.uid)
          .collection("followers")
          .doc(currentUser)
          .set({});
      userCollection
          .doc(currentUser)
          .collection("following")
          .doc(widget.uid)
          .set({});
      setState(() {
        isFollowing = true;
        followers++;
      });
    } else {
      userCollection
          .doc(widget.uid)
          .collection("followers")
          .doc(currentUser)
          .delete();
      userCollection
          .doc(currentUser)
          .collection("following")
          .doc(widget.uid)
          .delete();
      setState(() {
        isFollowing = false;
        followers--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  getAllData() async {
    setState(() {
      _isLoading = true;
    });
    myPdf = FirebaseFirestore.instance
        .collection("pdf-posts")
        .where("uid", isEqualTo: widget.uid)
        .orderBy("datePublished", descending: true)
        .get();
    DocumentSnapshot userDoc = await userCollection.doc(widget.uid).get();
    username = userDoc.data()["username"];
    profilePic = userDoc.data()["profilePhoto"];
    currentUser = FirebaseAuth.instance.currentUser.uid;
    grade = userDoc.data()["grade"];
    schoolName = userDoc.data()["schoolName"];
    stream = userDoc.data()["stream"];
    bio = userDoc.data()["bio"];

    var docs = await FirebaseFirestore.instance
        .collection("pdf-posts")
        .where("uid", isEqualTo: widget.uid)
        .get();
    for (var item in docs.docs) {
      likes += item.data()["likes"].length;
      noOfPosts += 1;
    }
    var followerDoc =
        await userCollection.doc(widget.uid).collection("followers").get();
    var followingDoc =
        await userCollection.doc(widget.uid).collection("following").get();
    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;

    userCollection
        .doc(widget.uid)
        .collection("followers")
        .doc(currentUser)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          isFollowing = true;
        });
      } else {
        setState(() {
          isFollowing = false;
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UniversalVariables().secondaryColor,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.black,
                          backgroundImage: NetworkImage(
                            profilePic,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          username,
                          style: GoogleFonts.lato(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: MenuItemWidget(
                                          title: followers.toString(),
                                          content: 'Followers',
                                        )),
                                        Expanded(
                                            child: MenuItemWidget(
                                          title: following.toString(),
                                          content: 'Following',
                                        )),
                                        Expanded(
                                            child: MenuItemWidget(
                                          title: likes.toString(),
                                          content: 'Likes',
                                        ))
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    bio,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Stream: ",
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        stream,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "School Name: ",
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        schoolName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Grade: ",
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        grade,
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            FirebaseAuth.instance.currentUser.uid != widget.uid
                                ? MaterialButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                    elevation: 0,
                                    height: 50,
                                    onPressed: () => followUser(),
                                    color: UniversalVariables().logoGreen,
                                    child: Text(
                                      isFollowing == false
                                          ? "Follow"
                                          : "Unfollow",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    textColor: Colors.white,
                                  )
                                : Text(""),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "${noOfPosts.toString()} Notes",
                              style: GoogleFonts.lato(
                                  fontSize: 20, color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: myPdf,
                              builder: (BuildContext coontext, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DocumentSnapshot posts =
                                        snapshot.data.docs[index];
                                    Timestamp timestamp =
                                        posts.data()["datePublished"];
                                    DateTime dateTime = timestamp.toDate();
                                    String timePosted =
                                        timeago.format(dateTime);
                                    isLiked = posts.data()["likes"].contains(
                                        FirebaseAuth.instance.currentUser.uid);
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Card(
                                        color:
                                            UniversalVariables().primaryColor,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  posts.data()["profilePic"],
                                                ),
                                              ),
                                              trailing:
                                                  posts.data()["uid"] ==
                                                          FirebaseAuth.instance
                                                              .currentUser.uid
                                                      ? PopupMenuButton<String>(
                                                          icon: Icon(
                                                            Icons.more_vert,
                                                            color: Colors.white,
                                                          ),
                                                          onSelected:
                                                              (String choice) {
                                                            if (choice ==
                                                                "Delete") {
                                                              return showDialog(
                                                                context:
                                                                    context,
                                                                builder: (ctx) =>
                                                                    AlertDialog(
                                                                  title: Text(
                                                                      "Delete Confirmation"),
                                                                  content: Text(
                                                                    "Are you sure you want to delete Your PDF?",
                                                                    style: GoogleFonts
                                                                        .lato(),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection("pdf-posts")
                                                                            .doc(posts.data()["id"])
                                                                            .delete();
                                                                        FirebaseStorage
                                                                            .instance
                                                                            .ref("pdf-notes")
                                                                            .child(FirebaseAuth.instance.currentUser.uid)
                                                                            .child(posts.data()["title"])
                                                                            .delete();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "Confirm",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          "Cancel"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return ["Delete"]
                                                                .map((String
                                                                    choice) {
                                                              return PopupMenuItem<
                                                                  String>(
                                                                value: choice,
                                                                child: Text(
                                                                    choice),
                                                              );
                                                            }).toList();
                                                          })
                                                      : Text(""),
                                              title: Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Wrap(
                                                  direction: Axis.vertical,
                                                  children: [
                                                    Text(
                                                      posts.data()["title"],
                                                      style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(timePosted,
                                                        style: GoogleFonts.lato(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left),
                                                  ],
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "Grade : " +
                                                          posts.data()["grade"],
                                                      style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "Notes for " +
                                                          posts.data()[
                                                              "subject"] +
                                                          " , " +
                                                          posts
                                                              .data()["stream"],
                                                      style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "Description: " +
                                                          posts.data()[
                                                              "description"],
                                                      style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      posts.data()[
                                                                  "username"] !=
                                                              null
                                                          ? "By " +
                                                              posts.data()[
                                                                  "username"]
                                                          : "",
                                                      style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          if (posts
                                                              .data()["likes"]
                                                              .contains(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      .uid)) {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "pdf-posts")
                                                                .doc(posts
                                                                        .data()[
                                                                    "id"])
                                                                .update({
                                                              "likes": FieldValue
                                                                  .arrayRemove([
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid
                                                              ]),
                                                            });
                                                            setState(() {
                                                              isLiked = false;
                                                            });
                                                          } else {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "pdf-posts")
                                                                .doc(posts
                                                                        .data()[
                                                                    "id"])
                                                                .update({
                                                              "likes": FieldValue
                                                                  .arrayUnion([
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid
                                                              ]),
                                                            });
                                                            setState(() {
                                                              isLiked = true;
                                                            });
                                                          }
                                                        },
                                                        icon: isLiked
                                                            ? Icon(
                                                                Icons.favorite,
                                                                color:
                                                                    Colors.red,
                                                                size: 30,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .favorite_border,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              ),
                                                      ),
                                                      Text(
                                                        posts
                                                            .data()["likes"]
                                                            .length
                                                            .toString(),
                                                        style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                      ),
                                                      IconButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                          MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                CommentScreen(
                                                              id: posts
                                                                  .data()["id"],
                                                              fileType: "pdf",
                                                            ),
                                                          ),
                                                        ),
                                                        icon: Icon(
                                                          Icons.comment,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                      Text(
                                                        posts
                                                            .data()[
                                                                "commentCount"]
                                                            .toString(),
                                                        style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
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
                      ]),
                ),
              ));
  }
}

class MenuItemWidget extends StatelessWidget {
  final String title;
  final String content;

  MenuItemWidget({@required this.title, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$title',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('$content',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}
