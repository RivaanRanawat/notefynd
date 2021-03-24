import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notefynd/screens/add_pdf_notes.dart';
import 'package:notefynd/universal_variables.dart';

class AddContent extends StatefulWidget {
  @override
  _AddContentState createState() => _AddContentState();
}

class _AddContentState extends State<AddContent> {
  pickVideo(ImageSource src) async {
    Navigator.of(context).pop();
    final video = await ImagePicker().getVideo(source: src);
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
                onPressed: () => pickVideo(ImageSource.camera),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        "Camera",
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
              onPressed: () => showOptionsDialog(context),
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
