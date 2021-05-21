import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/pages/profileScreen/user_profile_screen.dart';
import 'package:notefynd/screens/comment_screen.dart';
import 'package:notefynd/screens/requestNotes/notes_request_see_screen.dart';
import 'package:notefynd/screens/pages/pdfs/pdf_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import "package:timeago/timeago.dart" as timeago;

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String remotePDFpath = "";
  Stream postStream;
  bool _isLoading = false;
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _gradeController = new TextEditingController();
  TextEditingController _subjectController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  Future<File> createFileOfPdfUrl(String url) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    setState(() {
      _isLoading = true;
    });
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
      setState(() {
        _isLoading = false;
      });
      if (remotePDFpath != null || remotePDFpath.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFScreen(path: remotePDFpath),
          ),
        );
      } else {
        print("please wait");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    postStream = FirebaseFirestore.instance
        .collection("pdf-posts")
        .orderBy("datePublished", descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _gradeController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
  }

  searchNotes(String notes) {
    print(notes);
    if (notes != "") {
      var posts = FirebaseFirestore.instance
          .collection("pdf-posts")
          .where("title", isGreaterThanOrEqualTo: notes)
          .snapshots();
      setState(() {
        postStream = posts;
      });
    } else {
      var posts = FirebaseFirestore.instance
          .collection("pdf-posts")
          .orderBy("datePublished", descending: true)
          .snapshots();
      setState(() {
        postStream = posts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false
        ? Scaffold(
            backgroundColor: UniversalVariables().secondaryColor,
            appBar: AppBar(
              backgroundColor: UniversalVariables().secondaryColor,
              title: TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: false,
                  hintText: "Search Notes",
                  hintStyle:
                      GoogleFonts.lato(fontSize: 18, color: Colors.white),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: searchNotes,
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline_outlined),
                  onPressed: () => Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: NotesRequestSeeScreen())),
                ),
              ],
              elevation: 0.25,
            ),
            body: StreamBuilder(
                stream: postStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (ctx, idx) {
                      DocumentSnapshot posts = snapshot.data.docs[idx];
                      Timestamp timestamp = posts.data()["datePublished"];
                      DateTime dateTime = timestamp.toDate();
                      String timePosted = timeago.format(dateTime);
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              createFileOfPdfUrl(posts.data()["pdfUrl"])
                                  .then((f) {
                                setState(() {
                                  remotePDFpath = f.path;
                                });
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                color: UniversalVariables().primaryColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => UserProfileScreen(
                                              posts.data()["uid"],
                                            ),
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            posts.data()["profilePic"],
                                          ),
                                        ),
                                      ),
                                      trailing:
                                          posts.data()["uid"] ==
                                                  FirebaseAuth
                                                      .instance.currentUser.uid
                                              ? PopupMenuButton<String>(
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white,
                                                  ),
                                                  onSelected: (String choice) {
                                                    if (choice == "Delete") {
                                                      return showDialog(
                                                        context: context,
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
                                                              onPressed: () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "pdf-posts")
                                                                    .doc(posts
                                                                            .data()[
                                                                        "id"])
                                                                    .delete();
                                                                FirebaseStorage
                                                                    .instance
                                                                    .ref(
                                                                        "pdf-notes")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                        .uid)
                                                                    .child(posts
                                                                            .data()[
                                                                        "title"])
                                                                    .delete();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                "Confirm",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "Cancel"),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else if (choice ==
                                                        "Edit") {
                                                      return showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            AlertDialog(
                                                          backgroundColor:
                                                              Color.fromRGBO(
                                                                  249,
                                                                  250,
                                                                  252,
                                                                  1),
                                                          title: Text("Edit"),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                  decoration: BoxDecoration(
                                                                      color: Color.fromRGBO(
                                                                          251,
                                                                          251,
                                                                          251,
                                                                          1),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.blue)),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _titleController,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: 10),
                                                                      labelText:
                                                                          "Title",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              color: Colors.black),
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                  decoration: BoxDecoration(
                                                                      color: Color.fromRGBO(
                                                                          251,
                                                                          251,
                                                                          251,
                                                                          1),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.blue)),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _descriptionController,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: 10),
                                                                      labelText:
                                                                          "Description",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              color: Colors.black),
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                  decoration: BoxDecoration(
                                                                      color: Color.fromRGBO(
                                                                          251,
                                                                          251,
                                                                          251,
                                                                          1),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.blue)),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _subjectController,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: 10),
                                                                      labelText:
                                                                          "Subject",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              color: Colors.black),
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                  decoration: BoxDecoration(
                                                                      color: Color.fromRGBO(
                                                                          251,
                                                                          251,
                                                                          251,
                                                                          1),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.blue)),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _gradeController,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: 10),
                                                                      labelText:
                                                                          "Grade",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              color: Colors.black),
                                                                      border: InputBorder
                                                                          .none,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "pdf-posts")
                                                                    .doc(posts
                                                                            .data()[
                                                                        "id"])
                                                                    .update({
                                                                  "description":
                                                                      _descriptionController
                                                                          .text,
                                                                  "grade":
                                                                      _gradeController
                                                                          .text,
                                                                  "subject":
                                                                      _subjectController
                                                                          .text,
                                                                  "title":
                                                                      _titleController
                                                                          .text
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                "Edit",
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return ["Edit", "Delete"]
                                                        .map((String choice) {
                                                      return PopupMenuItem<
                                                          String>(
                                                        value: choice,
                                                        child: Text(choice),
                                                      );
                                                    }).toList();
                                                  })
                                              : Text(""),
                                      title: Padding(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            Text(posts.data()["title"],
                                                style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.fade,
                                                maxLines: 2),
                                            Text(
                                              timePosted,
                                              style: GoogleFonts.lato(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
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
                                              "Grade : " +
                                                  posts.data()["grade"],
                                              style: GoogleFonts.lato(
                                                color: Colors.white,
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
                                                  color: Colors.white,
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
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Text(
                                              posts.data()["username"] != null
                                                  ? "By " +
                                                      posts.data()["username"]
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
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .uid)) {
                                                    FirebaseFirestore.instance
                                                        .collection("pdf-posts")
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
                                                        .collection("pdf-posts")
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
                                                        size: 30,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.white,
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
                                                    .data()["commentCount"]
                                                    .toString(),
                                                style: GoogleFonts.lato(
                                                  color: Colors.white,
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
                                              posts.data()["isVerified"] == true
                                                  ? Icon(
                                                      Icons.verified_rounded,
                                                      color: Colors.white,
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 10),
              Text(
                "Loading The Notes. Please Wait.",
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ],
          );
  }
}
