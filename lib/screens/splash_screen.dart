import "package:flutter/material.dart";
import 'package:notefynd/universal_variables.dart';

class SplashScreen extends StatelessWidget {
  final UniversalVariables _universalVariables = UniversalVariables();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _universalVariables.primaryColor,
      body: Center(child: Image.asset("assets/images/logo.png"),
      ),
    );
  }
}
