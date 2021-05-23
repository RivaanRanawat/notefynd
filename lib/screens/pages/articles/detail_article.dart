import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:provider/provider.dart';

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
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 13),
            Text(
              title,
              style: GoogleFonts.lato(
                  fontSize: 30,
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 2),
                  child: Text(
                    "Published $timePublished",
                    style: TextStyle(
                      color: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .subtitle2
                          .color,
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
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
