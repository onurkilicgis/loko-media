import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/services/utils.dart';
import 'package:share_plus/share_plus.dart';

import '../models/Album.dart';
import '../view/AlbumShare.dart';
import '../view/AudioView.dart';
import '../view/PdfView.dart';
import '../view/TxtView.dart';

class Media_VM {
  static openMediaLongPDialog(context, model, Medias media) {
    String acmaAdi = media.fileType == 'image'
        ? 'a204'.tr
        : media.fileType == 'video'
            ? 'a205'.tr
            : media.fileType == 'audio'
                ? 'a206'.tr
                : media.fileType == 'txt'
                    ? 'a207'.tr
                    : 'a208'.tr;

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
                  title: Text('a209'.tr),
                  onTap: () {
                    model.selectMedia(media);

                    Navigator.pop(context);
                  },
                ),
                ListTile(
                    title: Text(acmaAdi),
                    onTap: () {
                      Navigator.pop(context);
                      if (acmaAdi == 'a204'.tr) {
                        model.openImage(media);
                      } else if (acmaAdi == 'a205'.tr) {
                        model.openLongVideo(media);
                      } else if (acmaAdi == 'a206'.tr) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AudioView(
                                  medias: media,
                                  appbarstatus: true,
                                )));
                      } else if (acmaAdi == 'a207'.tr) {
                        dynamic tip = json.decode(media.settings!);
                        if (tip['type'] == 'txt') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  TxtView(medias: media, appbarstatus: true)));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PdfView(medias: media, appbarstatus: true)));
                        }
                      }
                    }),
                ListTile(
                    title: Text('a190'.tr),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AlbumShare(
                                      type: 'medya',
                                      info: {
                                        'id': media.id,
                                        'name': media.name,
                                        'kimlere': 'kisi'
                                      },
                                      mediaList: [
                                        media
                                      ])));
                    }),
                ListTile(
                    title: Text('a191'.tr),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AlbumShare(
                                    type: 'medya',
                                    info: {
                                      'id': media.id,
                                      'name': media.name,
                                      'kimlere': 'herkes'
                                    },
                                    mediaList: [media],
                                  )));
                    }),
                ListTile(
                    title: Text('a210'.tr),
                    onTap: () async {
                      await Share.shareXFiles([XFile(media.path!)]);
                      Navigator.pop(context);
                    }),
                ListTile(
                    title: Text('a241'.tr),
                    onTap: () async {
                      Util.evetHayir(context, 'a211'.tr, 'a212'.tr,
                          (cevap) async {
                        if (cevap == true) {
                          List<int> tekSilinen = [];
                          tekSilinen.add(media.id!);
                          int silinenDosyaSayisi =
                              await AlbumDataBase.mediaMultiDelete(tekSilinen);
                          SBBildirim.bilgi(Utils.getComplexLanguage(
                              'a213'.tr, {'sayi': silinenDosyaSayisi}));
                          model.setState(() {
                            model.deleteMediasFromList(tekSilinen);
                          });
                        }
                        Navigator.pop(context);
                      });
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
          actions: [
            Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.people,
                  ),
                  title: Text('a190'.tr),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlbumShare(
                                type: 'medyalar',
                                info: {'id': 1, 'name': '', 'kimlere': 'kisi'},
                                mediaList: seciliMedias)));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.people,
                  ),
                  title: Text('a191'.tr),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlbumShare(
                                type: 'medyalar',
                                info: {
                                  'id': 1,
                                  'name': '',
                                  'kimlere': 'herkes'
                                },
                                mediaList: seciliMedias)));
                  },
                ),
                ListTile(
                    leading: Icon(Icons.link),
                    title: Text('a214'.tr),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('a215'.tr),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('a210'.tr),
                    onTap: () async {
                      List<XFile> secilenler = [];
                      for (int i = 0; i < seciliMedias.length; i++) {
                        secilenler.add(XFile(seciliMedias[i].path!));
                      }
                      await Share.shareXFiles(secilenler, text: 'a216'.tr);
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
