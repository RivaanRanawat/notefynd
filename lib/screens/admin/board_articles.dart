import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/admin/admin_add_article.dart';
import 'package:notefynd/screens/admin/detail_article.dart';
import 'package:notefynd/universal_variables.dart';
import "package:timeago/timeago.dart" as tago;

class AddBoardArticles extends StatefulWidget {
  @override
  _AddBoardArticlesState createState() => _AddBoardArticlesState();
}

class _AddBoardArticlesState extends State<AddBoardArticles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("articles").snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (ctx, idx) {
                var posts = snapshot.data.docs[idx];
                Timestamp timestamp = posts.data()["datePublished"];
                DateTime dateTime = timestamp.toDate();
                String timePosted = tago.format(dateTime);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DetailArticle()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: UniversalVariables().primaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListTile(
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
                                        title: Text("Delete Confirmation"),
                                        content: Text(
                                          "Are you sure you want to delete Your PDF?",
                                          style: GoogleFonts.lato(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("articles")
                                                  .doc(posts.data()["id"])
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Confirm",
                                              style:
                                                  TextStyle(color: Colors.red),
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
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return ["Delete"].map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                }),
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
                                ],
                              ),
                            ),
                            subtitle: Flexible(
                              child: Text(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => AdminAddArticle())),
      ),
    );
  }
}
