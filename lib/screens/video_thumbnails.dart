import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/video_details_screen.dart';
import 'package:notefynd/universal_variables.dart';
import "package:timeago/timeago.dart" as timeago;

class VideoThumbnails extends StatefulWidget {
  @override
  _VideoThumbnailsState createState() => _VideoThumbnailsState();
}

class _VideoThumbnailsState extends State<VideoThumbnails> {
  Stream _videoStream;

  @override
  void initState() {
    super.initState();
    _videoStream = FirebaseFirestore.instance
        .collection("videos")
        .orderBy("datePublished", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: StreamBuilder(
        stream: _videoStream,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Container(
            child: ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot listData = snapshot.data.docs[index];
                Timestamp timestamp = listData.data()["datePublished"];
                DateTime dateTime = timestamp.toDate();
                String timePosted = timeago.format(dateTime);
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => VideoDetailScreen(
                          channelAvatar: listData.data()["profilePic"],
                          channelName: listData.data()["username"],
                          thumbnail: listData.data()["previewImage"],
                          title: listData.data()["title"],
                          video: listData.data()["videoUrl"],
                          id: listData.data()["id"]
                          ),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  NetworkImage(listData.data()["previewImage"]),
                              fit: BoxFit.cover),
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        dense: true,
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(listData.data()["profilePic"]),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            listData.data()["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          "${listData.data()["username"]} - $timePosted",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Container(
                            margin: const EdgeInsets.only(bottom: 20.0),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1.0,
                color: Colors.grey,
              ),
              itemCount: snapshot.data.docs.length,
            ),
          );
        },
      ),
    );
  }
}
