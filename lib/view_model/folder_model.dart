import 'dart:io';
import 'dart:io' as ioo;
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  // çekilen,seçilen resim, video, ses ve yazıları sisteme kayıt eder.
  static Future<String?> createFile(String path, Uint8List bytes,
      String fileName, String miniFileName, String fileType) async {
    // uygulamanını kök klasörünün yolunu aldı (yol:path, kökklasör:root)
    final Directory root = await getApplicationDocumentsDirectory();
    // oluşturmak istediğimiz dosyayı ilgili albümün neresine koyacağımızın yolunu tanıtıyoruz yani dosyanın path bilgisi
    final Directory filePath = Directory('${root.path}/$path/${fileName}');
    // dosya oluşturmak için orada bir dosya yolu tanımlıyor.
    var file = await ioo.File(filePath.path);
    // burda oluşturmak istediğimiz dosyanın içerisine veriyi ekliyor.
    await file.writeAsBytes(bytes);
    final Directory miniFilePath =
        Directory('${root.path}/$path/${miniFileName}');

    var mini = await ioo.File(miniFilePath.path);

    if (fileType == 'video') {
      final bytes = await VideoThumbnail.thumbnailData(
        video: mini.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
    }
    // resimler için haritada gösterebilmek adına küçük bir emitosyanunu oluşturuyoruz. yeniden boyutlandırıyoruz.
    // bunu yapmazsak harita kasılır.
    if (fileType == 'image') {
      Image? image = decodeImage(bytes);
      Image thumbnail = copyResize(image!, width: 128);

      List<String> parcalar = miniFileName.split('.');
      String uzanti = parcalar[parcalar.length - 1];
      uzanti = uzanti.toLowerCase();
      switch (uzanti) {
        case 'jpg':
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodeJpg(thumbnail));
            break;
          }
        case 'png':
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodePng(thumbnail));
            break;
          }
        case 'gif':
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodeGif(thumbnail));
            break;
          }
        case 'jpeg':
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodeJpg(thumbnail));
            break;
          }
        case 'bmp':
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodeBmp(thumbnail));
            break;
          }
        default:
          {
            new ioo.File(miniFilePath.path)
                .writeAsBytesSync(encodeJpg(thumbnail));
            break;
          }
      }
    }
    return file.path;
  }
}
