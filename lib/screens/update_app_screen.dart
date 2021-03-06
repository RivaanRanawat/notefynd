import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Please update your app to the latest version to use it.",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          GestureDetector(
            onTap: () async {
              await canLaunch(
                      "https://play.google.com/store/apps/details?id=com.rivaan.notefynd")
                  ? await launch(
                      "https://play.google.com/store/apps/details?id=com.rivaan.notefynd")
                  : ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Could not launch url"),
                      ),
                    );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.googlePlay,
                  color: Colors.blue,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(
                    "Click here to update",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
