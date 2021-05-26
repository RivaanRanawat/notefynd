import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/pages/creator/creator_studio_screen.dart';
import 'package:notefynd/screens/pages/profileScreen/edit_profile_screen.dart';
import 'package:notefynd/provider/AuthMethods.dart';
import 'package:notefynd/provider/Creator.dart';
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
  void getData() async {
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
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (creatorText != null)
      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
          title: Text(
            "Your Profile",
            style: TextStyle(
                color: Provider.of<ThemeModel>(context)
                    .currentTheme
                    .textTheme
                    .headline6
                    .color),
          ),
          actions: [
            PopupMenuButton<String>(
                color: Provider.of<ThemeModel>(context)
                    .currentTheme
                    .backgroundColor,
                icon: Icon(
                  Icons.more_vert,
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                ),
                onSelected: (String choice) async {
                  if (choice == "Light Mode") {
                    Provider.of<ThemeModel>(context, listen: false).toggleTheme(
                      ThemeType.Dark,
                    );
                  } else if (choice == "Dark Mode") {
                    Provider.of<ThemeModel>(context, listen: false).toggleTheme(
                      ThemeType.Light,
                    );
                  } else if (choice == "Default Mode") {
                    Provider.of<ThemeModel>(context, listen: false).toggleTheme(
                      ThemeType.Default,
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return ["Light Mode", "Dark Mode", "Default Mode"]
                      .map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(
                        choice,
                        style: Provider.of<ThemeModel>(context, listen: false)
                            .currentTheme
                            .textTheme
                            .headline6,
                      ),
                    );
                  }).toList();
                })
          ],
        ),
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        body: Container(
          child: Stack(
            children: [
              ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: GradientColors.facebookMessenger,
                  )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 2 - 64,
                  top: MediaQuery.of(context).size.height / 4,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Text(
                    username,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: Provider.of<ThemeModel>(context)
                            .currentTheme
                            .textTheme
                            .headline6
                            .color),
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
                                  username: username,
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreatorStudioScreen()));
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
        ),
      );
    else
      return Center(child: CircularProgressIndicator());
  }
}
