import 'package:flutter/services.dart';

class FileHelper{

  static Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }
}