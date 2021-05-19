import "package:flutter/material.dart";
import 'package:notefynd/universal_variables.dart';

class ViewRequestedNotesScreen extends StatefulWidget {
  @override
  _ViewRequestedNotesScreenState createState() => _ViewRequestedNotesScreenState();
}

class _ViewRequestedNotesScreenState extends State<ViewRequestedNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().primaryColor,
      body: Container(child: Text("hell")),
    );
  }
}