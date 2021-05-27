import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String postsNo = "";
  String usersNo = "";
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var postDoc =
        await FirebaseFirestore.instance.collection("pdf-posts").get();
    QuerySnapshot userSnap =
        await FirebaseFirestore.instance.collection("users").get();
    setState(() {
      postsNo = postDoc.docs.length.toString();
      usersNo = userSnap.docs.length.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        title: Text(
          "Statistics",
          style:
              Provider.of<ThemeModel>(context).currentTheme.textTheme.headline6,
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.2,
              height: MediaQuery.of(context).size.height/4.5,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                color:
                    Provider.of<ThemeModel>(context).currentTheme.primaryColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30, top: 20, bottom: 10),
                      child: Text(
                        postsNo != null ? postsNo : "0",
                        style: TextStyle(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 65,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Posts",
                        style: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .subtitle2
                                .color,
                            fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2.2,
              height: MediaQuery.of(context).size.height/4.5,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                color:
                    Provider.of<ThemeModel>(context).currentTheme.primaryColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30, top: 20, bottom: 10),
                      child: Text(
                        usersNo != null ? usersNo : "0",
                        style: TextStyle(
                          color: Provider.of<ThemeModel>(context)
                              .currentTheme
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 65,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Users",
                        style: TextStyle(
                            color: Provider.of<ThemeModel>(context)
                                .currentTheme
                                .textTheme
                                .subtitle2
                                .color,
                            fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
