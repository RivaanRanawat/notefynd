import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _isLoading = false;

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode _emailFocusNode;
  FocusNode _passwordFocusNode;
  FocusNode _confirmPasswordFocusNode;

  UniversalVariables _universalVariables = UniversalVariables();
  void _signUpUser(String email, String password, BuildContext context,
      String fullName) async {
    try {
      setState(() {
        _isLoading = true;
      });
      String result = await Provider.of<AuthMethods>(context, listen: false)
          .signUpUser(email, password, fullName);
      if (result == "success") {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        var snackbar = new SnackBar(
          content: new Text(result),
          duration: Duration(seconds: 2),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _universalVariables.primaryColor,
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
                      'Sign Up To Notefynd to continue!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          color: Colors.white, fontSize: 28),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Share. View. Earn',
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
                          color: _universalVariables.secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        controller: _fullNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Username",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: _universalVariables.secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        focusNode: _emailFocusNode,
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
                        onFieldSubmitted: (_) =>
                            _passwordFocusNode.requestFocus(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: _universalVariables.secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _confirmPasswordFocusNode.requestFocus(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: _universalVariables.secondaryColor,
                          border: Border.all(color: Colors.blue)),
                      child: TextFormField(
                        focusNode: _confirmPasswordFocusNode,
                        controller: _confirmPasswordController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(
                            Icons.lock_open,
                            color: Colors.white,
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    SizedBox(height: 30),
                    Builder(
                      builder: (ctx) => MaterialButton(
                        minWidth: double.maxFinite,
                        height: 50,
                        elevation: 0,
                        onPressed: () {
                          if (_passwordController.text.isNotEmpty &&
                              _confirmPasswordController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _fullNameController.text.isNotEmpty) {
                            if (_passwordController.text ==
                                _confirmPasswordController.text) {
                              _signUpUser(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                  _fullNameController.text);
                            } else {
                              var snackbar = new SnackBar(
                                content: new Text("Passwords Dont Match"),
                                duration: Duration(seconds: 2),
                              );
                              _scaffoldKey.currentState.showSnackBar(snackbar);
                            }
                          } else {
                            var snackbar = new SnackBar(
                              content: new Text("Please enter all the fields"),
                              duration: Duration(seconds: 2),
                            );
                            _scaffoldKey.currentState.showSnackBar(snackbar);
                          }
                        },
                        color: _universalVariables.logoGreen,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                                builder: (context) => LoginScreen(),
                              ),
                            ),
                            child: Text(
                              'Login?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
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
