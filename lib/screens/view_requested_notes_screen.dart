import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/universal_variables.dart';
import "package:timeago/timeago.dart" as timeago;

class ViewRequestedNotesScreen extends StatefulWidget {
  @override
  _ViewRequestedNotesScreenState createState() =>
      _ViewRequestedNotesScreenState();
}

class _ViewRequestedNotesScreenState extends State<ViewRequestedNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().primaryColor,
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
                  return ListTile(
                    title: Text(
                      requestPost["topic"],
                      style: TextStyle(
                          color: Colors.white,
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
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Text(
                          "Requested $timePosted",
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                    trailing: Text(
                      requestPost["grade"],
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
