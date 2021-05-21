import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:notefynd/provider/Creator.dart';
import 'dart:io';

import 'package:notefynd/universal_variables.dart';
import 'package:provider/provider.dart';

class AddPdfNotes extends StatefulWidget {
  @override
  _AddPdfNotesState createState() => _AddPdfNotesState();
}

class _AddPdfNotesState extends State<AddPdfNotes> {
  File _file;
  String fileName;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  var _isLoading = false;
  String _grade = "";
  var _universalVariables = UniversalVariables();

  handleClassButtonClick(String grade) {
    setState(() {
      _grade = grade;
    });
    print(_grade);
  }

  uploadPdftoFirebase() async {
    setState(() {
      _isLoading = true;
    });
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _subjectController.text.isNotEmpty &&
        _grade.isNotEmpty &&
        _file != null) {
      var result = await Provider.of<Creator>(context, listen: false)
          .storePdfNotes(_file, fileName, _titleController.text,
              _subjectController.text, _descriptionController.text, _grade);
      setState(() {
        _isLoading = false;
      });
      if (result == "success") {
        setState(() {
          _titleController.text = "";
          _descriptionController.text = "";
          _subjectController.text = "";
          _file = null;
        });
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Posted!"),
          duration: Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Enter all the fields"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables().secondaryColor,
      body: _isLoading == false
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  _file != null
                      ? Center(child: Text(fileName))
                      : Text(
                          "",
                          style: TextStyle(color: Colors.white),
                        ),
                  Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          File file = File(result.files.single.path);

                          setState(() {
                            _file = file;
                            fileName = result.files.single.name;
                          });
                        } else {
                          print("in sooth ik not why i am so sad");
                        }
                      },
                      child: Text(
                        "Select PDF",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Container(
                    margin: EdgeInsets.all(10),
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
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: UniversalVariables().secondaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Description",
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: UniversalVariables().secondaryColor,
                        border: Border.all(color: Colors.blue)),
                    child: TextFormField(
                      controller: _subjectController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Subject",
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 19.0, right: 19.0, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Class",
                            style: GoogleFonts.lato(
                                color: Colors.white, fontSize: 14)),
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
                                    ? _universalVariables.logoGreen
                                    : _universalVariables.secondaryColor,
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
                                    ? _universalVariables.logoGreen
                                    : _universalVariables.secondaryColor,
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
                                    ? _universalVariables.logoGreen
                                    : _universalVariables.secondaryColor,
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
                                    ? _universalVariables.logoGreen
                                    : _universalVariables.secondaryColor,
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
                                      ? _universalVariables.logoGreen
                                      : _universalVariables.secondaryColor,
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
                                      ? _universalVariables.logoGreen
                                      : _universalVariables.secondaryColor,
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
                                      ? _universalVariables.logoGreen
                                      : _universalVariables.secondaryColor,
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
                                      ? _universalVariables.logoGreen
                                      : _universalVariables.secondaryColor,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  MaterialButton(
                    minWidth: 150,
                    elevation: 0,
                    height: 50,
                    onPressed: uploadPdftoFirebase,
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
          : Center(child: CircularProgressIndicator()),
    );
  }
}