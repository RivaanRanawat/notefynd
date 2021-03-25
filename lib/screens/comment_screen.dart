import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/universal_variables.dart';
import "package:timeago/timeago.dart" as Tago;

class CommentScreen extends StatefulWidget {
  final String profilePic;
  final String id;
  CommentScreen({@required this.profilePic, @required this.id});
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  String uid;
  TextEditingController commentsController = TextEditingController();
  var videoColection = FirebaseFirestore.instance.collection("pdf-posts");
  var userCollection = FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
  }

  uploadComment() async {
    if (commentsController.text.isNotEmpty) {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      var allDocs =
          await videoColection.doc(widget.id).collection("comments").get();
      int len = allDocs.docs.length;
      videoColection
          .doc(widget.id)
          .collection("comments")
          .doc("Comment $len")
          .set({
        "username": userDoc.data()["username"],
        "uid": uid,
        "profilePic": widget.profilePic,
        "comment": commentsController.text,
        "likes": [],
        "time": DateTime.now(),
        "id": "Comment $len"
      });
      commentsController.clear();
      DocumentSnapshot doc = await videoColection.doc(widget.id).get();
      videoColection.doc(widget.id).update({
        "commentCount": doc.data()["commentCount"] + 1,
      });
    } else {
      print("empty");
    }
  }

  likeComment(String id) async {
    DocumentSnapshot doc = await videoColection
        .doc(widget.id)
        .collection("comments")
        .doc(id)
        .get();
    if (doc.data()["likes"].contains(uid)) {
      videoColection.doc(widget.id).collection("comments").doc(id).update({
        "likes": FieldValue.arrayRemove([uid]),
      });
    } else {
      videoColection.doc(widget.id).collection("comments").doc(id).update({
        "likes": FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UniversalVariables().secondaryColor,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: videoColection
                        .doc(widget.id)
                        .collection("comments")
                        .snapshots(),
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot comment =
                                snapshot.data.docs[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                backgroundImage:
                                    NetworkImage(comment.data()["profilePic"]),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    "${comment.data()["username"]}",
                                    style: GoogleFonts.lato(
                                        fontSize: 22,
                                        color: UniversalVariables().logoGreen,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${comment.data()["comment"]}",
                                    style: GoogleFonts.lato(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${Tago.format(comment.data()["time"].toDate())}",
                                        style: GoogleFonts.lato(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "${comment.data()["likes"].length} likes",
                                        style: GoogleFonts.lato(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: InkWell(
                                onTap: () => likeComment(comment.data()["id"]),
                                child: Icon(
                                  comment.data()["likes"].contains(uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 25,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: TextFormField(
                    controller: commentsController,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Comment",
                      labelStyle: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => uploadComment(),
                    child: Text(
                      "Send",
                      style:
                          GoogleFonts.lato(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
