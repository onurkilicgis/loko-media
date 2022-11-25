import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loko_media/view_model/layout.dart';

import '../services/MyLocal.dart';

class APP_VM {

  static getAramaKutusu(BuildContext context, app){
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              top: 12,
              right: 12,
            ),
            child: SizedBox(
              height: context.dynamicHeight(15),
              child: TextField(
                controller: app.searchController,
                textInputAction: TextInputAction.search,
                textAlign: TextAlign.left,
                cursorColor: const Color(0xff017eba),
                style: TextStyle(
                    color: Color(0xff9cddff), fontSize: 11),
                decoration: InputDecoration(
                    suffixIcon: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 36,
                            width: 30,
                            child: IconButton(
                                tooltip:
                                'Albüm Görünüm Değiştirme',
                                onPressed: () async {
                                  if (app.cardType == 'GFCard') {
                                    await MyLocal.setStringData(
                                        'card-type', 'ListTile');
                                    app.setState(() {
                                      app.cardType = 'ListTile';
                                    });
                                  } else {
                                    await MyLocal.setStringData(
                                        'card-type', 'GFCard');
                                    app.setState(() {
                                      app.cardType = 'GFCard';
                                    });
                                  }
                                  app.getAlbumList();
                                },
                                icon: Icon(
                                  Icons.apps,
                                  size: context.dynamicWidth(24),
                                  color: Color(0xff017eba),
                                )),
                          ),
                          SizedBox(
                            height: 36,
                            width: 30,
                            child: IconButton(
                                tooltip: 'Albüm Sıralama',
                                onPressed: () {},
                                icon: Icon(
                                  Icons.sort,
                                  size: context.dynamicWidth(24),
                                  color: Color(0xff017eba),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 36,
                              width: 30,
                              child: IconButton(
                                  tooltip: 'Albüm Filtreleme',
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.filter_alt,
                                    size:
                                    context.dynamicWidth(24),
                                    color: Color(0xff017eba),
                                  )),
                            ),
                          )
                        ]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xff017eba),
                      size: 18,
                    ),
                    labelText: 'Albüm Arama',
                    labelStyle: TextStyle(
                        color: Color(0xff017eba),
                        fontSize: context.dynamicWidth(28)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff017eba),
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff017eba),
                        ))),
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  static albumSilmeDialog(context,album,app,silmeSonrasi){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(12))),
            backgroundColor: Theme.of(context)
                .bottomNavigationBarTheme
                .backgroundColor,
            title: Text('Albüm Silme İşlemi'),
            content: Text(
                '"${album.name}" Adlı albümü silmeyek istediğinize emin misiniz?',style: TextStyle(fontSize: 14)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        app.deleteAAlbum(album.id!);
                        silmeSonrasi();
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
  }

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
                      app.albumAktifEt(album);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.list_alt),
                      title: Text('Albümün İçindekileri Listele'),
                      onTap: () async {
                        app.albumMedyalariniAc(album);
                        Navigator.pop(context);
                      }),
                  ListTile(
                      leading: Icon(FontAwesomeIcons.mapLocation),
                      title: Text('Haritada Göster'),
                      onTap: () async {
                        app.albumuHaritadaGoster(album);
                        Navigator.pop(context);
                      }),
                  ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Albümü Paylaş'),
                      onTap: () {
                        Navigator.pop(context);
                        getShareDialog(context);
                      }),
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
                      albumSilmeDialog(context, album, app,(){
                        Navigator.pop(context);
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
