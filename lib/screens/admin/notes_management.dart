import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/notes_request_see_screen.dart';
import 'package:notefynd/screens/pages/pdf_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:page_transition/page_transition.dart';
import "dart:async";
import "dart:io";
import 'package:path_provider/path_provider.dart';
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
    print(notes);
    if (notes != "") {
      var posts = FirebaseFirestore.instance
          .collection("pdf-posts")
          .where("title", isGreaterThanOrEqualTo: notes)
          .get();
      setState(() {
        searchResult = posts;
      });
    } else {
      var posts = FirebaseFirestore.instance
          .collection("pdf-posts")
          .orderBy("datePublished", descending: true)
          .get();
      setState(() {
        searchResult = posts;
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
            body: FutureBuilder(
                future: searchResult,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
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
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          posts.data()["profilePic"],
                                        ),
                                      ),
                                      trailing: PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                          ),
                                          onSelected: (String choice) {
                                            if (choice == "Delete") {
                                              return showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(
                                                      "Delete Confirmation"),
                                                  content: Text(
                                                    "Are you sure you want to delete Your PDF?",
                                                    style: GoogleFonts.lato(),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "pdf-posts")
                                                            .doc(posts
                                                                .data()["id"])
                                                            .delete();
                                                        FirebaseStorage.instance
                                                            .ref("pdf-notes")
                                                            .child(FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)
                                                            .child(posts.data()[
                                                                "title"])
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
                                            } else if (choice == "Verify") {
                                              return showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text("Verification"),
                                                  content: Text(
                                                    "Are you sure you want to verify these notes?",
                                                    style: GoogleFonts.lato(),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "pdf-posts")
                                                            .doc(posts["id"])
                                                            .update({
                                                          "isVerified": true
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        "Confirm",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return ["Delete", "Verify"]
                                                .map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice,
                                                child: Text(choice),
                                              );
                                            }).toList();
                                          }),
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            Text(
                                              posts.data()["title"],
                                              style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            Row(children: [
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
                                              SizedBox(width: 10),
                                              posts.data()["isVerified"] == true
                                                  ? Icon(
                                                      Icons.verified_rounded,
                                                      color: Colors.white,
                                                    )
                                                  : Container()
                                            ]),
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
                                              "School : " +
                                                  posts.data()["schoolName"],
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 14),
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
