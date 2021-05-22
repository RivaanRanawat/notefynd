import 'package:flutter/material.dart';

class UniversalVariables {
// Colours
  // primary -> Color(0xff18203d)
  // secondary -> Color(0xff232c51)

// ADMIN
  // primary --> Color(0xFF2A2D3E)
  // secondary -> Color.fromRGBO(32, 35, 50, 1)

// Dogehouse
  // primary -> Color.fromRGBO(21, 26, 33, 1)
  // secondary -> Color.fromRGBO(12, 14, 18, 1)
  final Color primaryColor = Color(0xFF2A2D3E);
  final Color secondaryColor = Color.fromRGBO(32, 35, 50, 1);
  final Color logoGreen = Color(0xff25bcbb);
}

ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xff1f655d),
    accentColor: Color(0xff40bf7a),
    textTheme: TextTheme(
        title: TextStyle(color: Color(0xff40bf7a)),
        subtitle: TextStyle(color: Colors.white),
        subhead: TextStyle(color: Color(0xff40bf7a))),
    appBarTheme: AppBarTheme(color: Color(0xff1f655d)));

ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Color(0xfff5f5f5),
    accentColor: Color(0xff40bf7a),
    textTheme: TextTheme(
        title: TextStyle(color: Colors.black54),
        subtitle: TextStyle(color: Colors.grey),
        subhead: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
        color: Color(0xff1f655d),
        actionsIconTheme: IconThemeData(color: Colors.white)));