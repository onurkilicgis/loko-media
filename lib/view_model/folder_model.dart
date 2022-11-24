import 'dart:io';
import 'dart:io' as ioo;
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class FolderModel {
  // Girilen parametredeki klasörü uygulamanın root'unda oluşturur
  static Future<String?> createFolder(String folderName) async {
    try {
      // Uygulamanın root klasörünün path'i
      final Directory root = await getApplicationDocumentsDirectory();
      // Uygulamanın rrotunda yeni bir klasör path'i oluşturuyoruz.
      // yani root içerisinde istediğimiz bir klasör oluşturması için.
      // C:/ali/mehmet/flutter_app/ -> root ve ahmet adından bir klasör oluşturmak istiyorsun
      // Yeni path C:/ali/mehmet/flutter_app/ahmet olur
      final Directory folder = Directory('${root.path}/$folderName/');

      if (await folder.exists()) {
        return folder.path;
      } else {
        // create metodu ile istediğimiz path adresinde klasör oluşturuyor.
        final Directory newFolder = await folder.create(recursive: true);
        return newFolder.path;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<String?> createFile(String path, Uint8List bytes,
      String fileName, String miniFileName) async {
    final Directory root = await getApplicationDocumentsDirectory();
    final Directory filePath = Directory('${root.path}/$path/${fileName}');
    var file = await ioo.File(filePath.path);
    await file.writeAsBytes(bytes);
    Image? image = decodeImage(bytes);
    Image thumbnail = copyResize(image!, width: 48);
    final Directory miniFilePath =
        Directory('${root.path}/$path/${miniFileName}');
    new ioo.File(miniFilePath.path).writeAsBytesSync(encodePng(thumbnail));
    return file.path;
  }
}
