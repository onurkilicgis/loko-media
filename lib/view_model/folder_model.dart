import 'dart:io';
import 'dart:io' as ioo;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FolderModel {
  static Future<String?> createFolder(String folderName) async {
    try {
      final Directory root = await getApplicationDocumentsDirectory();

      final Directory folder = Directory('${root.path}/$folderName/');

      if (await folder.exists()) {
        return folder.path;
      } else {
        final Directory newFolder = await folder.create(recursive: true);
        return newFolder.path;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<String?> createFile(
      String path, Uint8List bytes, String fileName) async {
    final Directory root = await getApplicationDocumentsDirectory();
    final Directory filePath = Directory('${root.path}/$path/${fileName}');
    var file = await ioo.File(filePath.path);
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
