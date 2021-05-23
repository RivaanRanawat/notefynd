import "package:flutter/material.dart";
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:provider/provider.dart';

class ThemeDrawer extends StatefulWidget {
  @override
  _ThemeDrawerState createState() => _ThemeDrawerState();
}

class _ThemeDrawerState extends State<ThemeDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  'Themes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Provider.of<ThemeModel>(context)
                          .currentTheme
                          .textTheme
                          .headline6
                          .color,
                      fontSize: 25),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Light Mode',
                style: TextStyle(
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                ),
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false)
                    .toggleTheme(ThemeType.Dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                ),
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false)
                    .toggleTheme(ThemeType.Light);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(
                'Default Mode',
                style: TextStyle(
                  color: Provider.of<ThemeModel>(context)
                      .currentTheme
                      .textTheme
                      .headline6
                      .color,
                ),
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false)
                    .toggleTheme(ThemeType.Default);
                Navigator.of(context).pop();
                },
            ),
          ],
        ),
      ),
    );
  }
}
