import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:notefynd/universal_variables.dart';
import 'package:video_player/video_player.dart';
import 'package:notefynd/widgets/controls_overlay.dart';

class VideoDetailScreen extends StatefulWidget {
  final thumbnail;
  final title;
  final channelAvatar;
  final channelName;
  final video;
  final id;

  VideoDetailScreen({
    @required this.thumbnail,
    @required this.title,
    @required this.channelAvatar,
    @required this.channelName,
    @required this.video,
    @required this.id,
  });
  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController _controller;
  bool doesLike;
  int likeCount;
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
        likeCount -=1;
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
        backgroundColor: UniversalVariables().secondaryColor,
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
            ClosedCaption(text: _controller.value.caption.text),
            ControlsOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }

  Widget _videoInfo() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
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
            ],
          ),
        )
      ],
    );
  }

  Widget _buildButtonColumn(IconData icon, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
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
              // subtitle: Text("1m subscribers"),
            ),
          ),
          // TextButton.icon(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.play_circle_filled,
          //       color: Colors.red,
          //     ),
          //     label: Text(
          //       "JOIN",
          //       style: TextStyle(color: Colors.red),
          //     ))
        ],
      ),
    );
  }

  Widget _moreInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: Text(
            "Up next",
            style: TextStyle(color: Colors.white),
          )),
          Text(
            "Autoplay",
            style: TextStyle(color: Colors.white),
          ),
          Switch(
            onChanged: (c) {},
            value: true,
          ),
        ],
      ),
    );
  }
}
