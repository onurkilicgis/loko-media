import 'package:flutter/material.dart';

import '../database/AlbumDataBase.dart';
import '../models/Album.dart';

class MediaProvider extends ChangeNotifier {
  // notifyListeners();
  List<Medias> fileList = [];

  getFileList(int album_id) async {
    List<Medias> file = await AlbumDataBase.getFiles(album_id);
    fileList = file;
    notifyListeners();
  }

  addMedia(Medias item) {
    fileList.add(item);
    notifyListeners();
  }

  deleteMedias(List<int> idList) {
    List<Medias> emtyp = [];
    for (int i = 0; i < fileList.length; i++) {
      Medias item = fileList[i];
      if (idList.indexOf(item.id!) == -1) {
        emtyp.add(item);
      }
    }
    fileList = emtyp;
    notifyListeners();
  }
}
