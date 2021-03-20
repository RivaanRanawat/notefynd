import "package:flutter/material.dart";
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:notefynd/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UniversalVariables universalVariables = UniversalVariables();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: universalVariables.primaryColor,
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              String result = await AuthMethods().signOut();
              if(result == "success") {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => LoginScreen()));
              }
            },
            child: Text("Log out"),
          ),
        ));
  }
}
