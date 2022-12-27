import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/services/utils.dart';
import 'package:share_plus/share_plus.dart';

import '../models/Album.dart';
import '../view/AudioView.dart';
import '../view/PdfView.dart';
import '../view/TxtView.dart';

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

                    Navigator.pop(context);
                  },
                ),
                ListTile(
                    title: Text(acmaAdi),
                    onTap: () {
                      Navigator.pop(context);
                      switch (acmaAdi) {
                        case 'Göster':
                          {
                            model.openImage(media);
                            break;
                          }
                        case 'İzle':
                          {
                            model.openLongVideo(media);
                            break;
                          }
                        case 'Dinle':
                          {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AudioView(
                                    medias: media, appbarstatus: true)));

                            break;
                          }
                        case 'Oku':
                          {
                            dynamic tip = json.decode(media.settings!);
                            if (tip['type'] == 'txt') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TxtView(
                                      medias: media, appbarstatus: true)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PdfView(
                                      medias: media, appbarstatus: true)));
                            }
                            break;
                          }
                      }
                    }),
                ListTile(title: Text('Herkesle Paylaş'), onTap: () {}),
                ListTile(
                    title: Text('Sosyal Medyada Paylaş'),
                    onTap: () async {
                      await Share.shareXFiles([XFile(media.path!)]);
                      Navigator.pop(context);
                    }),
                ListTile(
                    title: Text('Sil'),
                    onTap: () async {
                      Util.evetHayir(context, 'Medya Silme İşlemi',
                          'Bu medya öğesini silmek istediğinize emin misiniz?',
                          (cevap) async {
                        if (cevap == true) {
                          List<int> tekSilinen = [];
                          tekSilinen.add(media.id!);
                          int silinenDosyaSayisi =
                              await AlbumDataBase.mediaMultiDelete(tekSilinen);

                          SBBildirim.bilgi(
                              '${silinenDosyaSayisi} Adet medya silinmiştir.');
                          model.setState(() {
                            model.deleteMediasFromList(tekSilinen);
                          });
                        }
                      });
                      Navigator.pop(context);
                    }),
              ],
            )
          ],
        );
      },
    );
  }

  static getMedyaShareDialog(context, List<Medias> seciliMedias) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0))),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          // content: Text('albüm adını giriniz'),
          actions: [
            Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.people,
                  ),
                  title: Text('Herkesle Paylaş'),
                  onTap: () {},
                ),
                ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Bağlantıyı Paylaş'),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Kullanıcıya Gönder'),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Sosyal Medyada Paylaş'),
                    onTap: () async {
                      List<XFile> secilenler = [];
                      for (int i = 0; i < seciliMedias.length; i++) {
                        secilenler.add(XFile(seciliMedias[i].path!));
                      }
                      await Share.shareXFiles(secilenler,
                          text: 'LokoMedia Tarafından Paylaşılan Dosyalar');
                      Navigator.pop(context);
                    }),
              ],
            )
          ],
        );
      },
    );
  }
}
