import 'package:flutter/material.dart';
import 'package:notefynd/universal_variables.dart';

enum ThemeType { Light, Dark, Royal, Default }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = darkTheme;

  toggleTheme(ThemeType _themeType) {
    if (_themeType == ThemeType.Dark) {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Default) {
      currentTheme = defaultTheme;
      _themeType = ThemeType.Default;
      return notifyListeners();
    }
  }
}