import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/pages/profileScreen/user_profile_screen.dart';
import 'package:notefynd/screens/comment_screen.dart';
import 'package:notefynd/screens/requestNotes/notes_request_see_screen.dart';
import 'package:notefynd/screens/pages/pdfs/pdf_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import "package:timeago/timeago.dart" as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String remotePDFpath = "";
  Stream postStream;
  var isSeacrh = false;
  bool _isLoading = false;
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _gradeController = new TextEditingController();
  TextEditingController _subjectController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  Future<File> createFileOfPdfUrl(String url, String title) async {
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
            builder: (context) => PDFScreen(path: remotePDFpath, title: title),
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
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _gradeController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
  }

  searchNotes(String notes) {
    if (notes != "") {
      postStream = FirebaseFirestore.instance
          .collection("pdf-posts")
          .where("title", isGreaterThanOrEqualTo: notes)
          .limit(10)
          .snapshots();
      setState(() {
        isSeacrh = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter topic to search.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false
        ? Scaffold(
            backgroundColor:
                Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor:
                  Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
              leading: Icon(
                Icons.search,
                color: Provider.of<ThemeModel>(context)
                    .currentTheme
                    .textTheme
                    .headline6
                    .color,
              ),
              title: TextFormField(
                decoration: InputDecoration(
                  filled: false,
                  hintText: "Search Notes",
                  hintStyle: GoogleFonts.lato(
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: searchNotes,
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_outlined,
                    color: Provider.of<ThemeModel>(context)
                        .currentTheme
                        .textTheme
                        .headline6
                        .color,
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: NotesRequestSeeScreen())),
                ),
              ],
              elevation: 0.25,
            ),
            body: !isSeacrh
                ? PaginateFirestore(
                    query: FirebaseFirestore.instance
                        .collection("pdf-posts")
                        .orderBy("datePublished", descending: true),
                    itemBuilderType: PaginateBuilderType.listView,
                    isLive: true,
                    itemBuilder: (index, context, snapshot) =>
                        listViewItemBuilder(snapshot),
                  )
                : StreamBuilder(
                    stream: postStream,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snap.data.docs.length,
                        itemBuilder: (ctx, idx) =>
                            listViewItemBuilder(snap.data.docs[idx]),
                      );
                    }))
        : Container(
            color:
                Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 10),
                Text(
                  "Loading The Notes. Please Wait.",
                  style: GoogleFonts.lato(
                    color: Provider.of<ThemeModel>(context)
                        .currentTheme
                        .textTheme
                        .headline6
                        .color,
                  ),
                ),
              ],
            ),
          );
  }

  Widget listViewItemBuilder(snapshot) {
    final posts = snapshot;
    Timestamp timestamp = posts.data()["datePublished"];
    DateTime dateTime = timestamp.toDate();
    String timePosted = timeago.format(dateTime);
    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          html.window.open(posts.data()["pdfUrl"], '_blank');
          html.Url.revokeObjectUrl(posts.data()["pdfUrl"]);
        } else {
          createFileOfPdfUrl(posts.data()["pdfUrl"], posts.data()["title"])
              .then((f) {
            setState(() {
              remotePDFpath = f.path;
            });
          });
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          color: Provider.of<ThemeModel>(context).currentTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
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
                trailing: posts.data()["uid"] ==
                        FirebaseAuth.instance.currentUser.uid
                    ? PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                        ),
                        onSelected: (String choice) {
                          if (choice == "Delete") {
                            return showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete Confirmation",
                                    style: Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .textTheme
                                        .headline6),
                                content: Text(
                                  "Are you sure you want to delete Your PDF?",
                                  style: GoogleFonts.lato(
                                      color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .headline6
                                          .color),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("pdf-posts")
                                          .doc(posts.data()["id"])
                                          .delete();
                                      FirebaseStorage.instance
                                          .ref("pdf-notes")
                                          .child(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .child(posts.data()["title"])
                                          .delete();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              ),
                            );
                          } else if (choice == "Edit") {
                            return showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor:
                                    Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .backgroundColor,
                                title: Text("Edit",
                                    style: Provider.of<ThemeModel>(context)
                                        .currentTheme
                                        .textTheme
                                        .headline6),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue)),
                                        child: TextFormField(
                                          controller: _titleController,
                                          decoration: InputDecoration(
                                            fillColor:
                                                Provider.of<ThemeModel>(context)
                                                    .currentTheme
                                                    .primaryColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: "Title",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue)),
                                        child: TextFormField(
                                          controller: _descriptionController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: "Description",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue)),
                                        child: TextFormField(
                                          controller: _subjectController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: "Subject",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.blue)),
                                        child: TextFormField(
                                          controller: _gradeController,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: "Grade",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      if (_titleController.text.isNotEmpty &&
                                          _gradeController.text.isNotEmpty &&
                                          _subjectController.text.isNotEmpty &&
                                          _descriptionController
                                              .text.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection("pdf-posts")
                                            .doc(posts.data()["id"])
                                            .update({
                                          "description":
                                              _descriptionController.text,
                                          "grade": _gradeController.text,
                                          "subject": _subjectController.text,
                                          "title": _titleController.text
                                        });

                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Please enter all the fields"),
                                        ));
                                      }
                                    },
                                    child: Text(
                                      "Edit",
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return ["Edit", "Delete"].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(
                                choice,
                                style: Provider.of<ThemeModel>(context,
                                        listen: false)
                                    .currentTheme
                                    .textTheme
                                    .headline6,
                              ),
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
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 2),
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
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Grade : " + posts.data()["grade"],
                        style: GoogleFonts.lato(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Notes for " +
                            posts.data()["subject"] +
                            " , " +
                            posts.data()["stream"],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Description: " + posts.data()["description"],
                        style: GoogleFonts.lato(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        posts.data()["username"] != null
                            ? "By " + posts.data()["username"]
                            : "",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (posts.data()["likes"].contains(
                                FirebaseAuth.instance.currentUser.uid)) {
                              FirebaseFirestore.instance
                                  .collection("pdf-posts")
                                  .doc(posts.data()["id"])
                                  .update({
                                "likes": FieldValue.arrayRemove(
                                    [FirebaseAuth.instance.currentUser.uid]),
                              });
                            } else {
                              FirebaseFirestore.instance
                                  .collection("pdf-posts")
                                  .doc(posts.data()["id"])
                                  .update({
                                "likes": FieldValue.arrayUnion(
                                    [FirebaseAuth.instance.currentUser.uid]),
                              });
                            }
                          },
                          icon: posts.data()["likes"].contains(
                                  FirebaseAuth.instance.currentUser.uid)
                              ? Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: Provider.of<ThemeModel>(context)
                                      .currentTheme
                                      .textTheme
                                      .headline6
                                      .color,
                                  size: 30,
                                ),
                        ),
                        Text(
                          posts.data()["likes"].length.toString(),
                          style: GoogleFonts.lato(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: CommentScreen(
                                id: posts.data()["id"],
                                fileType: "pdf",
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.comment,
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            size: 30,
                          ),
                        ),
                        Text(
                          posts.data()["commentCount"].toString(),
                          style: GoogleFonts.lato(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        posts.data()["isVerified"] == true
                            ? Icon(
                                Icons.verified_rounded,
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .headline6
                                    .color,
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
    );
  }
}
