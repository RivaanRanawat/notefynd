import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:video_player/video_player.dart';

class ConfirmVideoScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  final ImageSource imageSource;

  ConfirmVideoScreen(this.videoFile, this.videoPath, this.imageSource);
  @override
  _ConfirmVideoScreenState createState() => _ConfirmVideoScreenState();
}

class _ConfirmVideoScreenState extends State<ConfirmVideoScreen> {
  VideoPlayerController controller;
  var isLoading = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(false);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  compressVideo() async {
    if (widget.imageSource == ImageSource.gallery) {
      return widget.videoFile;
    } else {
      final compressedVideo = await flutterVideoCompress.compressVideo(
        widget.videoPath,
        quality: VideoQuality.MediumQuality,
      );
      return File(compressedVideo.path);
    }
  }

  getPreviewImage() async {
    final previewImage =
        await flutterVideoCompress.getThumbnailWithFile(widget.videoPath);
    return previewImage;
  }

  uploadVideoToStorage(String id) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("videos")
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(id)
        .putFile(await compressVideo());
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  uploadImageToStorage(String id) async {
    String downloadUrl;
    UploadTask uploadTask;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('video-images')
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(id);
    uploadTask = ref.putFile(await getPreviewImage());
    downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  uploadVideo() async {
    setState(() {
      isLoading = true;
    });
    try {
      var uid = FirebaseAuth.instance.currentUser.uid;
      print("started");
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      print("goes");
      print("hopefully");
      String stream = userDoc["stream"];
      String grade = userDoc["grade"];
      print("works");
      if (_descriptionController.text.isNotEmpty &&
          _titleController.text.isNotEmpty &&
          _subjectController.text.isNotEmpty &&
          _schoolController.text.isNotEmpty) {
        print("nice");
        String video = await uploadVideoToStorage(_titleController.text);
        print("maybe");
        String previewImage = await uploadImageToStorage(_titleController.text);
        print("idk");
        FirebaseFirestore.instance
            .collection("videos")
            .doc(_titleController.text)
            .set({
          "username": userDoc.data()["username"],
          "uid": uid,
          "profilePic": userDoc.data()["profilePhoto"],
          "likes": [],
          "comments": [],
          "videoUrl": video,
          "previewImage": previewImage,
          "description": _descriptionController.text,
          "title": _titleController.text,
          "subject": _subjectController.text,
          "school": _schoolController.text,
          "stream": stream,
          "grade": grade,
          "datePublished": Timestamp.now(),
        });

        Navigator.of(context).pop();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: isLoading == false
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: UniversalVariables().secondaryColor,
                              border: Border.all(color: Colors.blue)),
                          child: TextFormField(
                            controller: _titleController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "Title",
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: UniversalVariables().secondaryColor,
                              border: Border.all(color: Colors.blue)),
                          child: TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "Description",
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: UniversalVariables().secondaryColor,
                              border: Border.all(color: Colors.blue)),
                          child: TextFormField(
                            controller: _subjectController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "Subject",
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: UniversalVariables().secondaryColor,
                              border: Border.all(color: Colors.blue)),
                          child: TextFormField(
                            controller: _schoolController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              labelText: "School",
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              minWidth: 150,
                              elevation: 0,
                              height: 50,
                              onPressed: () => uploadVideo(),
                              color: Colors.blue,
                              child: Text(
                                "Share!",
                                style: GoogleFonts.lato(
                                    fontSize: 20, color: Colors.white),
                              ),
                              textColor: Colors.white,
                            ),
                            MaterialButton(
                              minWidth: 150,
                              elevation: 0,
                              height: 50,
                              onPressed: () => Navigator.of(context).pop(),
                              color: UniversalVariables().logoGreen,
                              child: Text(
                                "Another Video",
                                style: GoogleFonts.lato(
                                    fontSize: 20, color: Colors.white),
                              ),
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Please wait while we are uploading..",
                    style:
                        GoogleFonts.raleway(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}
