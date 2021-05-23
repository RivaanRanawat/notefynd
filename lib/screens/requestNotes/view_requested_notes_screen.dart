import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';
import "package:timeago/timeago.dart" as timeago;

class ViewRequestedNotesScreen extends StatefulWidget {
  final status;
  ViewRequestedNotesScreen({@required this.status});

  @override
  _ViewRequestedNotesScreenState createState() =>
      _ViewRequestedNotesScreenState();
}

class _ViewRequestedNotesScreenState extends State<ViewRequestedNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("postRequests")
              .orderBy("datePublished", descending: true)
              .snapshots(),
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
                  DocumentSnapshot requestPost = snapshot.data.docs[idx];
                  Timestamp timestamp = requestPost.data()["datePublished"];
                  DateTime dateTime = timestamp.toDate();
                  String timePosted = timeago.format(dateTime);
                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ListTile(
                      title: Text(
                        requestPost["topic"],
                        style: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .headline6
                                .color,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              requestPost["subject"],
                              style: TextStyle(
                                  color: Provider.of<ThemeModel>(context)
                                      .currentTheme
                                      .textTheme
                                      .headline6
                                      .color,
                                  fontSize: 16),
                            ),
                          ),
                          Text(
                            "Requested $timePosted",
                            style: TextStyle(
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .subtitle2
                                    .color),
                          )
                        ],
                      ),
                      trailing: Text(
                        requestPost["grade"],
                        style: GoogleFonts.lato(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 22,
                        ),
                      ),
                      leading: widget.status == "admin"
                          ? IconButton(
                              icon: Icon(
                                Icons.check,
                                color: Provider.of<ThemeModel>(context)
                                    .currentTheme
                                    .textTheme
                                    .headline6
                                    .color,
                              ),
                              onPressed: () {
                                return showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor:
                                        Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .backgroundColor,
                                    title: Text(
                                      "Notes Confirmation",
                                      style: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme
                                          .headline6,
                                    ),
                                    content: Text(
                                      "Are you sure notes of ${requestPost["topic"]} have been posted?",
                                      style: GoogleFonts.lato(
                                          color:
                                              Provider.of<ThemeModel>(context)
                                                  .currentTheme
                                                  .textTheme
                                                  .headline6
                                                  .color),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection("postRequests")
                                              .doc(requestPost["requestID"])
                                              .delete();
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop("dialog");
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("dialog"),
                                        child: Text("Cancel"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
