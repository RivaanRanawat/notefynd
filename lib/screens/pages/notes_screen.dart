import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/pages/pdf_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:path_provider/path_provider.dart';
import "package:timeago/timeago.dart" as timeago;

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String remotePDFpath = "";
  Stream fileStream;
  bool _isLoading = false;

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
    fileStream = FirebaseFirestore.instance.collection("pdf-posts").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false
        ? StreamBuilder(
            stream: fileStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
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
                          createFileOfPdfUrl(posts.data()["pdfUrl"]).then((f) {
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
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      Text(
                                        posts.data()["likes"].length.toString(),
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          posts.data()["title"],
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
                                              0.05,
                                        ),
                                        SafeArea(
                                          child: Text(
                                            timePosted,
                                            style: GoogleFonts.lato(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Standard : " +
                                              posts.data()["standard"],
                                          style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Notes for " +
                                              posts.data()["subject"] +
                                              ", " +
                                              posts.data()["stream"],
                                          style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Description: " +
                                              posts.data()["description"],
                                          style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          posts.data()["username"] != null
                                              ? "By " + posts.data()["username"]
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
            })
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
