import 'package:flutter/material.dart';
import 'package:loko_media/services/utils.dart';

import '../models/Album.dart';

class Media_VM {
  static openMediaLongPDialog(context, model, Medias media) {
    String acmaAdi = media.fileType == 'image'
        ? 'Göster'
        : media.fileType == 'video'
            ? 'İzle'
            : media.fileType == 'audio'
                ? 'Dinle'
                : media.fileType == 'txt'
                    ? 'Oku'
                    : 'Aç';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0))),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          actions: [
            Column(
              children: [
                ListTile(
                  title: Text('Seç'),
                  onTap: () {
                    model.selectMedia(media);
                  },
                ),
                ListTile(title: Text(acmaAdi), onTap: () {}),
                ListTile(title: Text('Paylaş'), onTap: () {}),
                ListTile(title: Text('Sosyal Medyada Paylaş'), onTap: () {}),
                ListTile(
                    title: Text('Sil'),
                    onTap: () {
                      Util.evetHayir(context, 'Medya Silme İşlemi',
                          'Bu medya öğesini silmek istediğinize emin misiniz?',
                          (cevap) {
                        if (cevap == true) {
                          SBBildirim.onay('Medya Silinmiştir');
                        }
                      });
                    }),
              ],
            )
          ],
        );
      },
    );
  }
}
