import 'dart:async';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  UniversalVariables _universalVariables = UniversalVariables();
  TextEditingController _descriptionController = TextEditingController();
  io.File _image;
  final picker = ImagePicker();
  PickedFile pickedFile;
  String downloadUrl;
  var _isLoading = false;
  Future getImage() async {
    pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = io.File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<firebase_storage.UploadTask> uploadImageToStorage(
      PickedFile pickedFile) async {
    firebase_storage.UploadTask uploadTask;
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child(FirebaseAuth.instance.currentUser.uid);
    ;
    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': pickedFile.path});
    uploadTask = ref.putFile(io.File(pickedFile.path), metadata);
    downloadUrl = await ref.getDownloadURL();
    return Future.value(uploadTask);
  }

  uploadDataToFirebase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_image != null && _descriptionController.text.isNotEmpty) {
        firebase_storage.UploadTask task =
            await uploadImageToStorage(pickedFile);
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({
          "bio": _descriptionController.text,
          "profilePhoto": downloadUrl
        });
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter a title and an image")));
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _universalVariables.secondaryColor,
      body: _isLoading == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _image == null
                          ? NetworkImage(
                              "https://i.stack.imgur.com/l60Hf.png",
                            )
                          : FileImage(_image),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: getImage,
                        icon: Icon(Icons.add_a_photo),
                        color: Colors.white,
                      ),
                    )
                  ]),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 70, horizontal: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: _universalVariables.secondaryColor,
                      border: Border.all(color: Colors.blue)),
                  child: TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      labelText: "Description",
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(color: Colors.white),
                      icon: Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    maxLength: 200,
                  ),
                ),
                MaterialButton(
                  minWidth: 150,
                  elevation: 0,
                  height: 50,
                  onPressed: uploadDataToFirebase,
                  color: UniversalVariables().logoGreen,
                  child: Text("Done"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  textColor: Colors.white,
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
