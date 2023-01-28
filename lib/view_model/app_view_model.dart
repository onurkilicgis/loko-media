import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/view/AlbumShare.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:share_plus/share_plus.dart';

import '../models/Album.dart';
import '../services/GPS.dart';
import '../services/MyLocal.dart';

class APP_VM {
  static getAramaKutusu(
    BuildContext context,
    app,
    album,
  ) {
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
                style: TextStyle(color: Color(0xff9cddff), fontSize: 11),
                decoration: InputDecoration(
                    suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 36,
                            width: 30,
                            child: IconButton(
                                tooltip: 'Albüm Görünüm Değiştirme',
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
                                  color:
                                      Theme.of(context).listTileTheme.iconColor,
                                )),
                          ),
                          SizedBox(
                            height: 36,
                            width: 30,
                            child: IconButton(
                                tooltip: 'Albüm Sıralama',
                                onPressed: () {
                                  getSiralamaDialog(context, app, album);
                                },
                                icon: Icon(
                                  Icons.sort,
                                  size: context.dynamicWidth(24),
                                  color:
                                      Theme.of(context).listTileTheme.iconColor,
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 36,
                              width: 30,
                              child: IconButton(
                                  tooltip: 'Albüm Filtreleme',
                                  onPressed: () {
                                    getFiltrelemeDialog(
                                      context,
                                      app,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.filter_alt,
                                    size: context.dynamicWidth(24),
                                    color: Theme.of(context)
                                        .listTileTheme
                                        .iconColor,
                                  )),
                            ),
                          )
                        ]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).listTileTheme.iconColor,
                      size: 18,
                    ),
                    labelText: 'Albüm Arama',
                    labelStyle: TextStyle(
                        color: Theme.of(context).listTileTheme.iconColor,
                        fontSize: context.dynamicWidth(28)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Theme.of(context).listTileTheme.iconColor!,
                    )),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Theme.of(context).listTileTheme.iconColor!,
                    ))),
                onChanged: (value) {
                  app.albumArama(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  static albumSilmeDialog(context, album, app, silmeSonrasi) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            title: Text('Albüm Silme İşlemi'),
            content: Text(
                '"${album.name}" Adlı albümü silmeyek istediğinize emin misiniz?',
                style: TextStyle(fontSize: 14)),
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
                      title: Text(' İçindekileri Listele'),
                      onTap: () async {
                        app.albumMedyalariniAc(album.id);
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
                        getShareDialog(context, album);
                      }),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                    ),
                    title: Text('Albümü Sil'),
                    onTap: () {
                      albumSilmeDialog(context, album, app, () {
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

  static getShareDialog(BuildContext context, Album album) {
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
                  leading: Icon(Icons.person),
                  title: Text('Kişiye Paylaş'),
                  onTap: () async {
                    List<Medias> listShare =
                        await AlbumDataBase.getFiles(album.id!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlbumShare(
                                  type: 'album',
                                  info: {
                                    'id': album.id,
                                    'name': album.name,
                                    'kimlere': 'kisi'
                                  },
                                  mediaList: listShare,
                                )));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.people,
                  ),
                  title: Text('Herkesle Paylaş'),
                  onTap: () async {
                    List<Medias> listShare =
                        await AlbumDataBase.getFiles(album.id!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlbumShare(
                                  type: 'album',
                                  info: {
                                    'id': album.id,
                                    'name': album.name,
                                    'kimlere': 'herkes'
                                  },
                                  mediaList: listShare,
                                )));
                  },
                ),
                /*ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Bağlantıyı Paylaş'),
                    onTap: () {}),*/
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Diğer Uygulamalarda Paylaş'),
                    onTap: () async {
                      List<XFile> files = [];
                      List<Medias> medias =
                          await AlbumDataBase.getFiles(album.id!);
                      for (int i = 0; i < medias.length; i++) {
                        files.add(XFile(medias[i].path!));
                      }
                      await Share.shareXFiles(files);

                      Navigator.pop(context);
                    }),
              ],
            )
          ],
        );
      },
    );
  }

  static getSiralamaDialog(context, app, album) {
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
                  title: Text(
                    'En Çok Medya Olanı Listele',
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () {
                    Comparator<Album> siralama =
                        (y, x) => x.itemCount!.compareTo(y.itemCount!);
                    app.filteredAlbumList.sort(siralama);
                    app.setState(() {
                      siralama;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                    title: Text(
                      'En Az Medya Olanı Listele',
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Comparator<Album> siralama =
                          (x, y) => x.itemCount!.compareTo(y.itemCount!);
                      app.filteredAlbumList.sort(siralama);
                      app.setState(() {
                        siralama;
                      });
                      Navigator.pop(context);
                    }),
                ListTile(
                    title: Text(
                      'Son Oluşturma Tarihine Göre Listele',
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Comparator<Album> siralama =
                          (y, x) => x.id!.compareTo(y.id!);
                      app.filteredAlbumList.sort(siralama);
                      app.setState(() {
                        siralama;
                      });
                      Navigator.pop(context);
                    }),
                ListTile(
                    title: Text(
                      'İlk Oluşturma Tarihine Göre Listele',
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Comparator<Album> siralama =
                          (x, y) => x.id!.compareTo(y.id!);
                      app.filteredAlbumList.sort(siralama);
                      app.setState(() {
                        siralama;
                      });
                      Navigator.pop(context);
                    }),
                ListTile(
                    title: Text(
                      'Bana En Yakın Mediaya Göre Listele',
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () async {
                      uzaklik(app);
                      Navigator.pop(context);
                    }),
              ],
            )
          ],
        );
      },
    );
  }

  static getFiltrelemeDialog(
    context,
    app,
  ) {
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
                  title: Text('Paylaşılmış Albümleri Göster'),
                  onTap: () {},
                ),
                /* ListTile(
                    title: Text('Yayınlanmış Albümleri Filtrele'),
                    onTap: () {}),*/
                ListTile(
                    title: Text(
                      'Resimli Albümleri Göster',
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () async {
                      List<Album> filterList = [];
                      filterList = await AlbumDataBase.getFilterAlbums('image');
                      app.setState(() {
                        app.filteredAlbumList = filterList;
                      });
                      Navigator.pop(context);
                    }),
                ListTile(
                  title: Text(
                    'Videolu Albümleri Göster',
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () async {
                    List<Album> filterList = [];
                    filterList = await AlbumDataBase.getFilterAlbums('video');
                    app.setState(() {
                      app.filteredAlbumList = filterList;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Sesli Albümleri Göster',
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () async {
                    List<Album> filterList = [];
                    filterList = await AlbumDataBase.getFilterAlbums('audio');
                    app.setState(() {
                      app.filteredAlbumList = filterList;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Dökümanlı Albümleri Göster',
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () async {
                    List<Album> filterList = [];
                    filterList = await AlbumDataBase.getFilterAlbums('txt');
                    app.setState(() {
                      app.filteredAlbumList = filterList;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Boş Albümleri Göster',
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: () {
                    List<Album> filterListitem = app.filteredAlbumList
                        .where((e) => e.itemCount == 0)
                        .toList();
                    app.setState(() {
                      app.filteredAlbumList = filterListitem;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  static uzaklikHesapla(double userEnlem, double userBoylam, double noktaEnlem,
      double noktaBoylam) {
    return sqrt(
        pow((userEnlem - noktaEnlem), 2) + pow((userBoylam - noktaBoylam), 2));
  }

  static uzaklik(app) async {
    dynamic positions = await GPS.getGPSPosition();

    double userEnlem = positions['latitude'];
    double userBoylam = positions['longitude'];

    List<Album> albumler = await AlbumDataBase.getAlbums();
    List<dynamic> listem = [];

    for (int i = 0; i < albumler.length; i++) {
      List<Medias> list = await AlbumDataBase.getFiles(albumler[i].id!);
      for (int j = 0; j < list.length; j++) {
        listem.add({
          'media_id': list[j].id,
          'album_id': albumler[i].id,
          'enlem': list[j].latitude,
          'boylam': list[j].longitude,
          'uzaklik': 0.0,
        });
      }
    }

    for (int i = 0; i < listem.length; i++) {
      dynamic item = listem[i];
      item['uzaklik'] =
          uzaklikHesapla(userEnlem, userBoylam, item['enlem'], item['boylam']);
    }

    listem.sort((a, b) {
      return a['uzaklik'].compareTo(b['uzaklik']);
    });

    // en yakın medyaların albüm id bilgisini aldık. ancak bu listede album_id bilgisi mükerrer değildir.
    // mükerrer = tekrarlı kayıt, aynı değerden birden fazla varsa mükerrer denir.
    List<int> album_id_list = [];
    for (int i = 0; i < listem.length; i++) {
      dynamic item = listem[i];
      if (album_id_list.indexOf(item['album_id']) == -1) {
        album_id_list.add(item['album_id']);
      }
    }

    //album_id_list de albümlerin id bilgisi var ve albüm nesnesini almak istiyoruz. returnda kullanmak için
    // bu kısım da album_id_list içerisindeki album_id leri kullanarak albumler dizisinden albümü bulup diziye ekler.
    List<Album> cikti = [];
    for (int i = 0; i < album_id_list.length; i++) {
      int album_id = album_id_list[i];
      Album album = albumler.firstWhere((a) => album_id == a.id);

      /* Album bulunanAlbum;
      for(int j=0;j<albumler.length;j++){
        Album item = albumler[j];
        if(item.id==album_id){
          bulunanAlbum = item;
          break;
        }
      }*/

      if (album != null) {
        cikti.add(album);
      }
    }

    app.setState(() {
      app.filteredAlbumList = cikti;
    });
    return app.filteredAlbumList;
  }
}
