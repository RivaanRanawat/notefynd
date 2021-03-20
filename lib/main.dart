import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/services/AuthMethods.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthMethods()),
      ],
      child: MaterialApp(
        title: 'Notefynd',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
