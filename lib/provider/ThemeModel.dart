import 'package:flutter/material.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { Light, Dark, Default }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme;
  String theme;
  SharedPreferences _pref;
  
  ThemeModel() {
    theme = "darkMode";
    checkTheme(); // add this line
  }

  _initPrefs() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    var prefTheme = _pref.getString("theme");
    if(prefTheme==null) {
      theme = "darkMode";
    } else {
      theme = prefTheme;
    }
    notifyListeners();
  }

  checkTheme() async {
    await _loadFromPrefs();
    print(theme + " aaa");
    if (theme == "lightMode") {
      currentTheme = lightTheme;
      return notifyListeners();
    }
    if (theme == "darkMode") {
      currentTheme = darkTheme;
      return notifyListeners();
    }
    if (theme == "defaultMode") {
      currentTheme = defaultTheme;
      return notifyListeners();
    }
  }

  toggleTheme(ThemeType _themeType) async {
    if (_themeType == ThemeType.Dark) {
      await _initPrefs();
      _pref.setString("theme", "lightMode");
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      await _initPrefs();
      _pref.setString("theme", "darkMode");
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Default) {
      await _initPrefs();
      _pref.setString("theme", "defaultMode");
      currentTheme = defaultTheme;
      _themeType = ThemeType.Default;
      return notifyListeners();
    }
  }
}
