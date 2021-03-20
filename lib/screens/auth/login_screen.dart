import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/screens/auth/signup_screen.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

enum LoginType { email, google }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _isLoading = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode myFocusNode;
  UniversalVariables _universalVariables = UniversalVariables();

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

  void _loginWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      String result = await Provider.of<AuthMethods>(context, listen: false)
          .loginWithEmailAndPassword(
              _emailController.text, _passwordController.text);
      if (result == "success") {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        setState(() {
          _isLoading = false;
        });
        var snackbar = new SnackBar(
          content: new Text(result),
          duration: Duration(seconds: 2),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      var snackbar = new SnackBar(
        content: new Text("Please fill in all the fields"),
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  void signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    String result = await Provider.of<AuthMethods>(context, listen: false).loginUserWithGoogle();
    if(result == "success") {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
    } else {
      setState(() {
        _isLoading = false;
      });
      var snackbar = new SnackBar(
          content: new Text(result),
          duration: Duration(seconds: 2),
        );
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
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
                      'Login To Notefynd and continue!',
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
                          color: _universalVariables.secondaryColor,
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
                      onPressed: _loginWithEmailAndPassword,
                      color: _universalVariables.logoGreen,
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
                      onPressed: signInWithGoogle,
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
