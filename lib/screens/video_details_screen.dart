import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:video_player/video_player.dart';
import 'package:notefynd/widgets/controls_overlay.dart';
import "package:timeago/timeago.dart" as Tago;

class VideoDetailScreen extends StatefulWidget {
  final thumbnail;
  final title;
  final channelAvatar;
  final channelName;
  final video;
  final id;
  final description;
  final school;
  final stream;
  final subject;
  final grade;

  VideoDetailScreen(
      {@required this.thumbnail,
      @required this.title,
      @required this.channelAvatar,
      @required this.channelName,
      @required this.video,
      @required this.id,
      @required this.description,
      @required this.school,
      @required this.stream,
      @required this.subject,
      @required this.grade});
  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController _controller;
  bool doesLike;
  int likeCount;
  String profilePic;
  bool didClickExtra = false;
  TextEditingController _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.video,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize();
    isLiked();
    getProfilePicOfUser();
  }

  isLiked() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("videos")
        .doc(widget.id)
        .get();
    likeCount = snap["likes"].length;
    if (snap["likes"].contains(FirebaseAuth.instance.currentUser.uid)) {
      setState(() {
        doesLike = true;
      });
    } else {
      setState(() {
        doesLike = false;
      });
    }
  }

  getProfilePicOfUser() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    profilePic = snap["profilePhoto"];
  }

  likeVideo(String id) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("videos").doc(id).get();
    if (doc.data()["likes"].contains(FirebaseAuth.instance.currentUser.uid)) {
      FirebaseFirestore.instance.collection("videos").doc(id).update({
        "likes":
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser.uid]),
      });
      setState(() {
        doesLike = false;
        likeCount -= 1;
      });
    } else {
      FirebaseFirestore.instance.collection("videos").doc(id).update({
        "likes": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser.uid]),
      });
      setState(() {
        doesLike = true;
        likeCount += 1;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _layouts = [
      _videoInfo(),
      _channelInfo(),
      _moreInfo(),
    ];

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      _layouts.clear();
    }

    return Scaffold(
        backgroundColor: UniversalVariables().primaryColor,
        body: Column(
          children: <Widget>[
            _buildVideoPlayer(context),
            Expanded(
              child: ListView(
                children: _layouts,
              ),
            )
          ],
        ));
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? 200.0
          : MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //       image: NetworkImage(widget.thumbnail), fit: BoxFit.cover),
      // ),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            ControlsOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }

  Widget _videoInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              didClickExtra = !didClickExtra;
            });
          },
          child: ListTile(
            title: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: didClickExtra
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: Text(
                          widget.description != null
                              ? "Description: " + widget.description
                              : "",
                          style: GoogleFonts.lato(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: Text(
                          "Notes for " + widget.subject + ", " + widget.stream,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: Text(
                          "Grade: " + widget.grade,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      onPressed: () => likeVideo(widget.id),
                      icon: Icon(
                        (doesLike != true
                            ? Icons.thumb_up_alt_outlined
                            : Icons.thumb_up),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    likeCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: Colors.white),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Share",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.cloud_download, color: Colors.white),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Download",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.playlist_add, color: Colors.white),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _channelInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.channelAvatar),
              ),
              title: Text(
                widget.channelName,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              // subtitle: Text(
              //   "0 subscribers",
              //   style: TextStyle(color: Colors.white70),
              // ),
            ),
          ),
          // TextButton.icon(
          //     onPressed: () {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(content: Text("Some thing to be done")));
          //     },
          //     icon: Icon(
          //       Icons.support,
          //       color: Colors.red,
          //     ),
          //     label: Text(
          //       "SUPPORT",
          //       style: TextStyle(color: Colors.red),
          //     ))
        ],
      ),
    );
  }

  Widget _moreInfo() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 16.0, right: 16.0),
            child: Text(
              "Comments",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0, left: 16.0, right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  profilePic != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(profilePic),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      // decoration: BoxDecoration(
                      //   color: UniversalVariables().secondaryColor,
                      // ),
                      child: TextFormField(
                        controller: _commentController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Add Public Comment",
                          labelStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_commentController.text.isNotEmpty) {
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();
                        var allDocs = await FirebaseFirestore.instance
                            .collection("videos")
                            .doc(widget.id)
                            .collection("comments")
                            .get();
                        int len = allDocs.docs.length;
                        FirebaseFirestore.instance
                            .collection("videos")
                            .doc(widget.id)
                            .collection("comments")
                            .doc("Comment $len")
                            .set({
                          "username": userDoc.data()["username"],
                          "uid": FirebaseAuth.instance.currentUser.uid,
                          "profilePic": userDoc.data()["profilePhoto"],
                          "comment": _commentController.text,
                          "likes": [],
                          "time": DateTime.now(),
                          "id": "Comment $len"
                        });
                        _commentController.clear();
                      }
                    },
                    padding: EdgeInsets.only(left: 10),
                    icon: Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("videos")
                .doc(widget.id)
                .collection("comments")
                .snapshots(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
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
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        "${comment.data()["comment"]}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
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
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${comment.data()["likes"].length} likes",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // trailing: InkWell(
                                //   onTap: () =>
                                //       likeComment(comment.data()["id"]),
                                //   child: Icon(
                                //     comment.data()["likes"].contains(uid)
                                //         ? Icons.favorite
                                //         : Icons.favorite_border,
                                //     size: 22,
                                //     color: Colors.white,
                                //   ),
                                // ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
