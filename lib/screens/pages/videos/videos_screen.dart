import "package:flutter/material.dart";
import 'package:notefynd/screens/pages/videos/video_thumbnails.dart';
import 'package:notefynd/universal_variables.dart';

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables().secondaryColor,
        title: Row(
          children: [
            Text("Videos"),
            ],
        ),
      ),
      backgroundColor: UniversalVariables().secondaryColor,
      body: VideoThumbnails(),
    );
  }
}
