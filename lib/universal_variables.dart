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
    backgroundColor: Color.fromRGBO(12, 14, 18, 1),
    primaryColor: Color.fromRGBO(21, 26, 33, 1),
    accentColor: Color.fromRGBO(253, 103, 104, 1),
    buttonColor: Color.fromRGBO(32, 35, 50, 1),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.white54),
    ));

ThemeData lightTheme = ThemeData.light().copyWith(
  backgroundColor: Color.fromRGBO(255, 255, 255, 1),
  primaryColor: Color.fromRGBO(251, 251, 251, 1),
  accentColor: Color.fromRGBO(4, 86, 243, 1),
  buttonColor: Color.fromRGBO(37, 38, 94, .7),
  textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Color.fromRGBO(37, 38, 94, .7))),
);

ThemeData defaultTheme = ThemeData.dark().copyWith(
    backgroundColor: Color(0xff232c51),
    primaryColor: Color(0xff18203d),
    accentColor: Colors.blue,
    buttonColor: Color(0xff18203d),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.white54),
    ));
