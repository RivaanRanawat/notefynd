import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/admin/admin_add_article.dart';
import 'package:notefynd/universal_variables.dart';

class AddBoardArticles extends StatefulWidget {
  @override
  _AddBoardArticlesState createState() => _AddBoardArticlesState();
}

class _AddBoardArticlesState extends State<AddBoardArticles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("articles").snapshots(),
        builder: (ctx, snapshot) {
          return Center(child: Text("show board articles"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => AdminAddArticle())),
      ),
    );
  }
}