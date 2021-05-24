import 'dart:async';
import "package:flutter/material.dart";
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:notefynd/provider/ThemeModel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFWebScreen extends StatefulWidget {
  final String path;
  final String title;

  PDFWebScreen({Key key, this.path, this.title}) : super(key: key);

  _PDFWebScreenState createState() => _PDFWebScreenState();
}

class _PDFWebScreenState extends State<PDFWebScreen>
    with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Provider.of<ThemeModel>(context).currentTheme.backgroundColor,
        title: Text(
          widget.title,
          style:
              Provider.of<ThemeModel>(context).currentTheme.textTheme.headline6,
        ),
      ),
      body: SfPdfViewer.network(widget.path,
          canShowScrollHead: false, canShowScrollStatus: false),
    );
  }
}
