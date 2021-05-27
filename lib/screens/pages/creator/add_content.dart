import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/pages/creator/add_pdf_notes.dart';
import 'package:notefynd/screens/pages/videos/confirm_video_screen.dart';
import "dart:io";

import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AddContent extends StatefulWidget {
  @override
  _AddContentState createState() => _AddContentState();
}

class _AddContentState extends State<AddContent> {
  pickVideo(ImageSource src) async {
    Navigator.of(context).pop();
    final video = await ImagePicker().getVideo(source: src);
    if (video != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) =>
              ConfirmVideoScreen(File(video.path), video.path, src)));
    }
  }

  showOptionsDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickVideo(ImageSource.gallery),
                child: Row(
                  children: [
                    Icon(Icons.image),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        "Gallery",
                        style: GoogleFonts.lato(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(Icons.cancel),
                    Padding(
                        padding: EdgeInsets.all(7),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.lato(fontSize: 20),
                        )),
                  ],
                ),
              ),
            ],
          );
        });
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setData();
  // }

  // setData() async {
  //   var post = await FirebaseFirestore.instance.collection("pdf-posts").get();
  //   post.docs.map((e) async {
  //     await FirebaseFirestore.instance.collection("pdf-posts").doc(e.data()["id"]).update({
  //       "videoUrl": ""
  //     });
  //   }).toList();

  //   var user = await FirebaseFirestore.instance.collection("users").get();
  //   user.docs.map((e) async {
  //     await FirebaseFirestore.instance.collection("users").doc(e.data()["uid"]).update({
  //       "username": e.data()["username"].replaceAll(" ", "").toLowerCase().trim()
  //     });
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .backgroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              minWidth: 150,
              elevation: 0,
              height: 50,
              onPressed: () => Navigator.of(context)
                  .push(PageTransition(child: AddPdfNotes(), type: PageTransitionType.bottomToTop)),
              color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .accentColor,
              child: Text("Add PDF"),
              textColor: Colors.white,
            ),
            // MaterialButton(
            //   minWidth: 150,
            //   elevation: 0,
            //   height: 50,
            //   onPressed: () => showOptionsDialog(context),
            //   color: Colors.blue,
            //   child: Text("Add Video"),
            //   textColor: Colors.white,
            // ),
          ],
        ),
      ),
    );
  }
}
