import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:notefynd/screens/admin_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:uuid/uuid.dart';
import "package:timeago/timeago.dart" as tago;

class AdminAddArticle extends StatefulWidget {
  @override
  _AdminAddArticleState createState() => _AdminAddArticleState();
}

class _AdminAddArticleState extends State<AdminAddArticle> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();

  var _isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().primaryColor,
      body: !_isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: UniversalVariables().secondaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Title",
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: UniversalVariables().secondaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _contentController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Content",
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                      ),
                      maxLines: 25,
                    ),
                  ),
                  SizedBox(height: 30),
                  MaterialButton(
                    minWidth: 150,
                    elevation: 0,
                    height: 50,
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      if (_titleController.text.isNotEmpty &&
                          _contentController.text.isNotEmpty) {
                        var uniqueId = Uuid().v1();
                        FirebaseFirestore.instance
                            .collection("articles")
                            .doc(uniqueId)
                            .set({
                          "title": _titleController.text,
                          "content": _contentController.text,
                          "datePublished": Timestamp.now(),
                          "likes": [],
                          "id": uniqueId,
                          "commentCount": 0,
                        });
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => AdminScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Enter Title and Content of Article.."),
                        ));
                      }
                    },
                    color: UniversalVariables().logoGreen,
                    child: Text("Share"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    textColor: Colors.white,
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
