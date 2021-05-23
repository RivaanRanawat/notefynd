import 'dart:async';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:notefynd/screens/home_screen.dart';
import 'package:notefynd/universal_variables.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final description;
  final schoolName;
  final stream;
  final grade;
  final image;
  final username;

  EditProfileScreen(
      {@required this.username,
      @required this.description,
      @required this.schoolName,
      @required this.stream,
      @required this.grade,
      @required this.image});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UniversalVariables _universalVariables = UniversalVariables();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  io.File _image;
  final picker = ImagePicker();
  PickedFile pickedFile;
  String downloadUrl;
  String _grade = "";
  String _stream = "Science";
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

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': pickedFile.path});
    uploadTask = ref.putFile(io.File(pickedFile.path), metadata);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    downloadUrl = await snapshot.ref.getDownloadURL();
    return Future.value(uploadTask);
  }

  handleClassButtonClick(String grade) {
    setState(() {
      _grade = grade;
    });
    print(_grade);
  }

  uploadDataToFirebase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_descriptionController.text.isNotEmpty &&
          _schoolNameController.text.isNotEmpty &&
          _stream != "" &&
          _nameController.text.isNotEmpty &&
          _grade != "") {
        if (_image != null) {
          await uploadImageToStorage(pickedFile);
        }
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({
          "bio": _descriptionController.text,
          "profilePhoto": _image != null
              ? downloadUrl
              : "https://i.stack.imgur.com/l60Hf.png",
          "schoolName": _schoolNameController.text,
          "stream": _stream,
          "grade": _grade,
          "username": _nameController.text.contains(" ")
              ? _nameController.text.replaceAll(" ", "").toLowerCase().trim()
              : _nameController.text.toLowerCase().trim()
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please enter all the fields with an image")));
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.description;
    _schoolNameController.text = widget.schoolName;
    _nameController.text = widget.username;
    downloadUrl = widget.image;
    _grade = widget.grade;
    _stream = widget.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .backgroundColor,
      body: _isLoading == false
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  Container(
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: _image == null
                            ? NetworkImage(
                                downloadUrl != ""
                                    ? downloadUrl
                                    : "https://i.stack.imgur.com/l60Hf.png",
                              )
                            : FileImage(_image),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: getImage,
                          icon: Icon(Icons.add_a_photo),
                          color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color,
                        ),
                      ),
                      Positioned(
                        left: 97,
                        bottom: 20,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              downloadUrl = "";
                            });
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      )
                    ]),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .primaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Username",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                        icon: Icon(
                          Icons.person,
                          color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .primaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Description",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                        icon: Icon(
                          Icons.description,
                          color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLines: 5,
                      maxLength: 200,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .primaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _schoolNameController,
                      style: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "School Name",
                        labelStyle: TextStyle(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                        icon: Icon(
                          Icons.school,
                          color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .primaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: DropdownButton<String>(
                      value: _stream,
                      icon: Icon(Icons.arrow_drop_down, color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                      dropdownColor: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .primaryColor,
                      style: GoogleFonts.lato(color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color),
                      items: <String>['Commerce', 'Science', 'Arts']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.1),
                            child: Text(value, style: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6,),
                          ),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          _stream = newValue;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 19.0, right: 19.0, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Class",
                            style: GoogleFonts.lato(
                                color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .textTheme.headline6.color, fontSize: 14)),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("7"),
                                color: _grade == "7"
                                    ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                    : Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                child: Text("7"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("8"),
                                color: _grade == "8"
                                    ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                    :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                child: Text("8"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("9"),
                                color: _grade == "9"
                                    ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                    :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                child: Text("9"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.20,
                                elevation: 0,
                                height: 50,
                                onPressed: () => handleClassButtonClick("10"),
                                color: _grade == "10"
                                    ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                    :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                child: Text("10"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("11"),
                                  color: _grade == "11"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("11"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("12"),
                                  color: _grade == "12"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("12"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("UG"),
                                  color: _grade == "UG"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("UG"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  elevation: 0,
                                  height: 50,
                                  onPressed: () => handleClassButtonClick("PG"),
                                  color: _grade == "PG"
                                      ? Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor
                                      :  Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .buttonColor,
                                  child: Text("PG"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 150,
                    elevation: 0,
                    height: 50,
                    onPressed: uploadDataToFirebase,
                    color: Provider.of<ThemeModel>(context)
                                          .currentTheme
                                          .accentColor,
                    child: Text("Update"),
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
//
