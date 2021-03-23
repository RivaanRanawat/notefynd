import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notefynd/screens/add_pdf_notes.dart';
import 'package:notefynd/screens/auth/details_screen.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/screens/splash_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:notefynd/services/Creator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthMethods()),
        ChangeNotifierProvider(create: (_) => Creator()),
      ],
      child: MaterialApp(
        title: 'Notefynd',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return SplashScreen();
              }
              if (userSnapshot.hasData) {
                return DetailsScreen();
              }
              return LoginScreen();
            }),
      ),
    );
  }
}
