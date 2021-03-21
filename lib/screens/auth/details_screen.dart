import "package:flutter/material.dart";
import 'package:notefynd/universal_variables.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  UniversalVariables _universalVariables = UniversalVariables();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _universalVariables.secondaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Stack(children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                  "https://i.stack.imgur.com/l60Hf.png",
                ),
              ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  onPressed: () {},
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
            onPressed: () {},
            color: UniversalVariables().logoGreen,
            child: Text("Done"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
