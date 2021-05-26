import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:provider/provider.dart';
import "package:timeago/timeago.dart" as Tago;

class CommentScreen extends StatefulWidget {
  final String id;
  final String fileType;
  CommentScreen({@required this.id, @required this.fileType});
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  String uid;
  TextEditingController commentsController = TextEditingController();
  var videoCollection = FirebaseFirestore.instance.collection("pdf-posts");
  var articleCollection = FirebaseFirestore.instance.collection("articles");
  var pdfCollection;
  var userCollection = FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    pdfCollection =
        widget.fileType == "pdf" ? videoCollection : articleCollection;
  }

  uploadComment() async {
    if (commentsController.text.isNotEmpty) {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      var allDocs =
          await pdfCollection.doc(widget.id).collection("comments").get();
      int len = allDocs.docs.length;
      pdfCollection
          .doc(widget.id)
          .collection("comments")
          .doc("Comment $len")
          .set({
        "username": userDoc.data()["username"],
        "uid": uid,
        "profilePic": userDoc.data()["profilePhoto"],
        "comment": commentsController.text,
        "likes": [],
        "time": DateTime.now(),
        "id": "Comment $len"
      });
      commentsController.clear();
      DocumentSnapshot doc = await pdfCollection.doc(widget.id).get();
      pdfCollection.doc(widget.id).update({
        "commentCount": doc.data()["commentCount"] + 1,
      });
    } else {
      print("empty");
    }
  }

  likeComment(String id) async {
    DocumentSnapshot doc =
        await pdfCollection.doc(widget.id).collection("comments").doc(id).get();
    if (doc.data()["likes"].contains(uid)) {
      pdfCollection.doc(widget.id).collection("comments").doc(id).update({
        "likes": FieldValue.arrayRemove([uid]),
      });
    } else {
      pdfCollection.doc(widget.id).collection("comments").doc(id).update({
        "likes": FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: pdfCollection
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
                            return Container(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  backgroundImage: NetworkImage(
                                      comment.data()["profilePic"]),
                                ),
                                title: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text(
                                        "${comment.data()["username"]}",
                                        style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color:
                                                Provider.of<ThemeModel>(context)
                                                    .currentTheme
                                                    .textTheme
                                                    .headline6
                                                    .color,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        "${comment.data()["comment"]}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Provider.of<ThemeModel>(context)
                                                  .currentTheme
                                                  .textTheme
                                                  .headline6
                                                  .color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      "${Tago.format(comment.data()["time"].toDate())}",
                                      style: TextStyle(
                                          color:
                                              Provider.of<ThemeModel>(context)
                                                  .currentTheme
                                                  .textTheme
                                                  .subtitle2
                                                  .color,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${comment.data()["likes"].length} likes",
                                      style: TextStyle(
                                          color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .subtitle2
                                            .color,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: InkWell(
                                  onTap: () =>
                                      likeComment(comment.data()["id"]),
                                  child: Icon(
                                    comment.data()["likes"].contains(uid)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 22,
                                    color: comment.data()["likes"].contains(uid)
                                        ? Colors.red
                                        : Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .headline6
                                            .color,
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                ListTile(
                  title: TextFormField(
                    controller: commentsController,
                    style: GoogleFonts.lato(fontSize: 16, color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .headline6
                                            .color),
                    decoration: InputDecoration(
                      hintText: "Comment",
                      hintStyle: GoogleFonts.lato(
                          color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .subtitle2
                                            .color, fontWeight: FontWeight.w700),
                      enabledBorder: UnderlineInputBorder(
                        // borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        // borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: uploadComment,
                    child: Text(
                      "Send",
                      style:
                          GoogleFonts.lato(fontSize: 16, color: Provider.of<ThemeModel>(context)
                                            .currentTheme
                                            .textTheme
                                            .headline6
                                            .color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
