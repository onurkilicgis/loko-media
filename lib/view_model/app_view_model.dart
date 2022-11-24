import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/MyLocal.dart';

class APP_VM {
  static showAlbumDialog(BuildContext context, app, album) async {
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
                    leading: Icon(Icons.check),
                    title: Text('Albümü Aktif Et'),
                    onTap: () async {
                      await MyLocal.setIntData('aktifalbum', album.id);
                      app.getAlbumList();

                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.list_alt),
                      title: Text('Albümün İçindekileri Listele'),
                      onTap: () async {
                        await MyLocal.setIntData('tiklananAlbum', album.id);
                        app.controller.index = 1;
                        app.setState(() {
                          app.tiklananAlbum = album.id!;
                        });
                        Navigator.pop(context);
                      }),
                  ListTile(
                      leading: Icon(FontAwesomeIcons.mapLocation),
                      title: Text('Haritada Göster'),
                      onTap: () async {
                        await MyLocal.setIntData('tiklananAlbum', album.id);
                        app.controller.index = 2;
                        app.setState(() {
                          app.tiklananAlbum = album.id!;
                        });
                        Navigator.pop(context);
                      }),
                  ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Albümü Paylaş'),
                      onTap: () {}),
                  ListTile(
                      leading: Icon(Icons.supervised_user_circle),
                      title: Text('Paylaşılan Kişiler Listesi'),
                      onTap: () {}),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                    ),
                    title: Text('Albümü Sil'),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14.0))),
                              backgroundColor: Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .backgroundColor,
                              title: Text('Albüm Silme'),
                              content: Text(
                                  '${album.name} Adlı Albümü Silmeye Emin Misiniz?'),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          app.deleteAAlbum(album.id!);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Evet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xfffd7e7e),
                                            ))),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Hayır',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xff80C783),
                                            )))
                                  ],
                                )
                              ],
                            );
                          });
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  static getShareDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Albüm Adı'),
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
                    title: Text('Mail Olarak Gönder'),
                    onTap: () {}),
                ListTile(
                    leading: Icon(FontAwesomeIcons.message),
                    title: Text('Sosyal Medyada Paylaş'),
                    onTap: () {}),
              ],
            )
          ],
        );
      },
    );
  }

  /*deleteAAlbum(int album_id) async {
    Album? silinecekAlbum = await AlbumDataBase.getAAlbum(album_id);
    Loading.waiting('${silinecekAlbum?.name} Adlı Albüm Siliniyor...');
    List<dynamic> files = [];
    files = await AlbumDataBase.getFiles(album_id);
    for (int i = 0; i < files.length; i++) {
      var item = files[i];
      File file = File(item.path);
      file.delete();
    }

    int silinenMediaSayisi = await AlbumDataBase.mediaDelete(album_id);
    int silinenAlbumSayisi = await AlbumDataBase.albumDelete(album_id);
    if (app.aktifalbum == album_id) {
      int lastAlbumId = await AlbumDataBase.getLastAlbum();
      await MyLocal.setIntData('aktifalbum', lastAlbumId);
      SBBildirim.bilgi(
          '${silinenMediaSayisi} Adet medya öğesi ve ${silinenAlbumSayisi} adet, ${silinecekAlbum?.name} adlı albüm silindi. Son albüm tekrar aktif edilmiştir.');
    } else {
      SBBildirim.bilgi(
          '${silinenMediaSayisi} Adet medya öğesi ve ${silinenAlbumSayisi} adet, ${silinecekAlbum?.name} adlı albüm silindi.');
    }
    Loading.close();
    app.getAlbumList();
  }*/
}
