import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/auth/login_screen.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/screens/splash_screen.dart';
import 'package:notefynd/provider/AuthMethods.dart';
import 'package:notefynd/provider/Creator.dart';
import 'package:notefynd/screens/update_app_screen.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => AuthMethods()),
        ChangeNotifierProvider(create: (_) => Creator()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String version;
  @override
  void initState() {
    getPackageInfo();
    super.initState();
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    print(packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notefynd',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeModel>(context).currentTheme,
      home: version == "1.0.10" && version != null
          ? StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, userSnapshot) {
                if (Provider.of<ThemeModel>(context).currentTheme == null) {
                  return SplashScreen();
                }
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SplashScreen();
                }
                if (userSnapshot.hasData) {
                  return HomeScreen();
                }
                return LoginScreen();
              })
          : UpdateAppScreen(),
    );
  }
}
