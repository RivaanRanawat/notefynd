import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/universal_variables.dart';

class DetailArticle extends StatelessWidget {
  final String title;
  final String content;
  final String timePublished;

  DetailArticle(
      {@required this.title,
      @required this.content,
      @required this.timePublished});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 13),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                title,
                style: GoogleFonts.lato(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    timePublished,
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 30),
              child: Text(
                content,
                style: TextStyle(
                  height: 2,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
