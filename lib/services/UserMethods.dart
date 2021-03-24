import 'dart:async';
import "dart:io";
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class UserMethods with ChangeNotifier {
  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url =
          "https://firebasestorage.googleapis.com/v0/b/notefynd-2523c.appspot.com/o/pdf-notes%2FR9T6ZvYuW5XHfPaqXn6MaWcaGu62%2FbioPrelimPaper.pdf?alt=media&token=88a711dd-afdf-4189-84e1-684d36a21849";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }
}
