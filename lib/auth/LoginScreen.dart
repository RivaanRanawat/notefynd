import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

enum LoginType {
  email,
  google
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _isLoading = false;

  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading == false
          ? Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login To Turn Pages and continue!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          color: Colors.white, fontSize: 28),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Enter your email and password below to continue to Turn Pages and let the reading schedule begin!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => myFocusNode.requestFocus(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        focusNode: myFocusNode,
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 30),
                    MaterialButton(
                      elevation: 0,
                      minWidth: double.maxFinite,
                      height: 50,
                      onPressed: () {
                        _loginUser(
                            type: LoginType.email,
                            email: _emailController.text,
                            password: _passwordController.text,
                            context: context);
                      },
                      color: logoGreen,
                      child: Text('Login',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0),
                          topLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      elevation: 0,
                      minWidth: double.maxFinite,
                      height: 50,
                      onPressed: () {
                        _loginUser(type: LoginType.google, context: context);
                      },
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.google),
                          SizedBox(width: 10),
                          Text('Sign In using Google',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0),
                          topLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            ),
                            child: Text('Sign Up?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
