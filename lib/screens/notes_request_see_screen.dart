import "package:flutter/material.dart";
import 'package:notefynd/screens/add_content.dart';
import 'package:notefynd/screens/request_new_notes_screen.dart';
import 'package:notefynd/screens/view_requested_notes_screen.dart';
import 'package:notefynd/universal_variables.dart';

class NotesRequestSeeScreen extends StatefulWidget {
  @override
  _NotesRequestSeeScreenState createState() => _NotesRequestSeeScreenState();
}

class _NotesRequestSeeScreenState extends State<NotesRequestSeeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(  
        length: 2,  
        child: Scaffold(  
          appBar: AppBar(  
            backgroundColor: UniversalVariables().primaryColor,
            title: Text('Request Notes'),  
            bottom: TabBar(  
              tabs: [  
                Tab(icon: Icon(Icons.add_to_home_screen_rounded), text: "Request"),  
                Tab(icon: Icon(Icons.remove_red_eye_sharp), text: "View")  
              ],  
            ),  
          ),  
          body: TabBarView(  
            children: [  
              RequestNewNotes(),  
              ViewRequestedNotesScreen(),  
            ],  
          ),  
        ),  
      ),  
    );  
  }
}