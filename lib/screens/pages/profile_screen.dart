import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/edit_profile_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:notefynd/services/Creator.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "";
  String creatorText;
  String profileUrl = "";
  String bio = "";
  String schoolName = "";
  String stream = "";
  String grade = "";
  String subject = "";
  void getUsername() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    setState(() {
      username = snapshot["username"];
      profileUrl = snapshot["profilePhoto"];
      bio = snapshot["bio"];
      schoolName = snapshot["schoolName"];
      stream = snapshot["stream"];
      grade = snapshot["grade"];
      subject = snapshot["subject"];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCreatorButton();
  }

  void getCreatorButton() async {
    String status = await Provider.of<Creator>(context).getCreatorStatus();
    print(status);
    if (status == "user") {
      creatorText = "Creator";
    } else {
      creatorText = "Creator Studio";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  Widget build(BuildContext context) {
    if (creatorText != null)
      return Container(
        child: Stack(
          children: [
            ClipPath(
              clipper: OvalBottomBorderClipper(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: GradientColors.facebookMessenger,
                )),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2 - 64,
                top: MediaQuery.of(context).size.height / 3.1,
              ),
              child: CircleAvatar(
                radius: 64,
                backgroundImage: profileUrl == ""
                    ? NetworkImage(
                        "https://i.stack.imgur.com/l60Hf.png",
                      )
                    : NetworkImage(profileUrl),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 350,
                ),
                Text(
                  username,
                  style:
                      GoogleFonts.montserrat(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        minWidth: 150,
                        elevation: 0,
                        height: 50,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => EditProfileScreen(
                                description: bio,
                                grade: grade,
                                image: profileUrl,
                                schoolName: schoolName,
                                stream: stream,
                                subject: subject,
                              ),
                            ),
                          );
                        },
                        color: UniversalVariables().logoGreen,
                        child: Text("Edit Profile"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        textColor: Colors.white,
                      ),
                      MaterialButton(
                        minWidth: 150,
                        elevation: 0,
                        height: 50,
                        onPressed: () {
                          if (creatorText == "Creator") {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({"status": "creator"});
                            setState(() {});
                          } else {
                            print("Navigate To Creator Studio");
                          }
                        },
                        color: Colors.blue,
                        child: Text(
                          creatorText,
                          style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    String result = await AuthMethods().signOut();
                    if (result == "success") {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx) => LoginScreen()));
                    }
                  },
                  elevation: 0,
                  minWidth: 350,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.red,
                  child: Text('Log out',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      );
    else
      return Center(child: CircularProgressIndicator());
  }
}
