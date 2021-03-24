import 'package:flutter/material.dart';
import 'package:notefynd/screens/add_pdf_notes.dart';
import 'package:notefynd/screens/add_videos.dart';
import 'package:notefynd/universal_variables.dart';

class AddContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              minWidth: 150,
              elevation: 0,
              height: 50,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => AddPdfNotes())),
              color: Colors.blue,
              child: Text("Add PDF"),
              textColor: Colors.white,
            ),
            MaterialButton(
              minWidth: 150,
              elevation: 0,
              height: 50,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => AddVideos())),
              color: Colors.blue,
              child: Text("Add Video"),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
