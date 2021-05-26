import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/pages/profileScreen/user_profile_screen.dart';
import 'package:notefynd/screens/requestNotes/notes_request_see_screen.dart';
import 'package:notefynd/screens/pages/pdfs/pdf_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import "dart:async";
import "dart:io";
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import "package:timeago/timeago.dart" as timeago;

class NotesManagement extends StatefulWidget {
  @override
  _NotesManagementState createState() => _NotesManagementState();
}

class _NotesManagementState extends State<NotesManagement> {
  String remotePDFpath = "";
  Stream fileStream;
  bool _isLoading = false;
  Future<QuerySnapshot> searchResult;
  Stream postStream;
  var isSeacrh = false;

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
  void initState() {
    super.initState();
    searchResult = FirebaseFirestore.instance
        .collection("pdf-posts")
        .orderBy("datePublished", descending: true)
        .get();
    fileStream = FirebaseFirestore.instance
        .collection("pdf-posts")
        .orderBy("datePublished", descending: true)
        .snapshots();
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
        createFileOfPdfUrl(posts.data()["pdfUrl"], posts.data()["title"])
            .then((f) {
          setState(() {
            remotePDFpath = f.path;
          });
        });
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
                trailing: PopupMenuButton<String>(
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
                            backgroundColor: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .backgroundColor,
                            title: Text("Delete Confirmation"),
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
                                      .child(
                                          FirebaseAuth.instance.currentUser.uid)
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
                      } else if (choice == "Verify") {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .backgroundColor,
                            title: Text("Verification"),
                            content: Text(
                              "Are you sure you want to verify these notes?",
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
                                      .doc(posts["id"])
                                      .update({"isVerified": true});
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Confirm",
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
                      return ["Delete", "Verify"].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    }),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                    )
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
