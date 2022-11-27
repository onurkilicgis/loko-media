import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/GPS.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/services/utils.dart';
import 'package:loko_media/view/Medya.dart';
import 'package:loko_media/view_model/app_view_model.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../services/Loader.dart';
import '../services/auth.dart';
import '../view_model/folder_model.dart';
import '../view_model/main_view_models.dart';
import 'Harita.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> with SingleTickerProviderStateMixin {
  late TabController controller;
  TextEditingController albumNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  late Color boxColor;

  AlbumDataBase albumDataBase = AlbumDataBase();
  //dolu havuzumuz
  List<Album> albumList = [];
  //istediğimiz zaman doldurup boşaltabileceğimiz havuzumuz
  List<Album> filteredAlbumList = [];
  int tiklananAlbum = -1;
  int aktifalbum = -1;
  late Album aktifAlbumItem;
  int aktifTabIndex = 0;
  String cardType = 'GFCard';
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');
      final imageTemporary = File(image.path);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = image.path.split('.');
      String extension = parts[parts.length - 1];
      String filename = 'image-' + now.toString() + '.' + extension;
      String miniFilename = 'image-mini-' + now.toString() + '.' + extension;
      Uint8List bytes = imageTemporary.readAsBytesSync();
      String? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}',
          bytes,
          filename,
          miniFilename,
          'image');
      Medias dbImage = new Medias(
        album_id: aktifAlbumId,
        name: filename,
        miniName: miniFilename,
        path: newPath,
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'image',
      );
      dbImage.insertData();
      await AlbumDataBase.insertFile(dbImage, (lastId) {
        dbImage.id = lastId;
        getAlbumList();
      });
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  getAlbumList() async {
    List<Album> dbAlbums = await AlbumDataBase.getAlbums();
    int aktif_album_no = await MyLocal.getIntData('aktifalbum');
    String cardType2 = await MyLocal.getStringData('card-type');
    Album album =
        dbAlbums.firstWhere((element) => aktif_album_no == element.id);
    setState(() {
      albumList = dbAlbums;
      filteredAlbumList = dbAlbums;
      aktifalbum = aktif_album_no;
      cardType = cardType2;
      aktifAlbumItem = album;
    });
  }

  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  AuthService _authService = AuthService();

  Card createCard(album, image, durum) {
    //xxx

    return Card(
      child: ListTile(
        onTap: () async {
          await MyLocal.setIntData('tiklananAlbum', album.id);
          setState(() {
            tiklananAlbum = album.id!;
            controller.index = 1;
          });
        },
        leading: image,
        title: Text(album.name),
        subtitle: Text('Öğe Sayısı : ${album.itemCount}, Durum : ${durum}'),
        trailing: IconButton(
            onPressed: () {
              APP_VM.showAlbumDialog(context, this, album);
            },
            icon: Icon(
              Icons.more_vert,
            )),
      ),
    );
  }

  Widget cardBottomButton(icon, onTap) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 32,
          width: 32,
          decoration: ShapeDecoration(
            color: Color(0xff202b40),
            shape: CircleBorder(),
          ),
          child: IconButton(
            iconSize: 16,
            icon: Icon(icon, color: Color(0xff017eba)),
            color: Colors.white,
            onPressed: () {
              onTap();
            },
          ),
        ),
      ),
    );
  }

  tabChange(index) {
    new Future.delayed(const Duration(milliseconds: 100), () {
      controller.index = index;
    });
  }

  albumAktifEt(album) {
    setState(() {
      aktifAlbumItem = album;
      aktifalbum = album.id;
    });
    MyLocal.setIntData('aktifalbum', album.id);
    SBBildirim.bilgi("${album.name} adlı albüm aktif edildi");
    getAlbumList();
  }

  albumMedyalariniAc(album_id) {
    setState(() {
      tiklananAlbum = album_id;
    });
    tabChange(1);
  }

  albumuHaritadaGoster(album) {
    if (album.itemCount > 0) {
      setState(() {
        tiklananAlbum = album.id;
      });
      tabChange(2);
    } else {
      SBBildirim.uyari('Haritada gösterilecek bir media öğesi bulunamadı');
    }
  }

  Widget createCustomCards(album, durum, isDark) {
    ImageProvider image;
    if (album.image == '') {
      if (isDark == 'dark') {
        image = new AssetImage('assets/images/album_dark.png');
      } else {
        image = new AssetImage('assets/images/album_light.png');
      }
    } else {
      image = FileImage(File(album.image.toString()));
    }
    return InkWell(
      onLongPress: () {
        APP_VM.showAlbumDialog(context, this, album);
      },
      onTap: () {
        albumMedyalariniAc(album.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: new BorderRadius.all(Radius.circular(8)),
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
        margin: EdgeInsets.all(4),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5, left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          album.name,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 4.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "Öğe Sayısı : ${album.itemCount.toString()}, Durum : ${durum}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 4.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //
                      cardBottomButton(Icons.delete, () {
                        APP_VM.albumSilmeDialog(context, album, this, () {});
                      }),
                      cardBottomButton(Icons.share, () {
                        APP_VM.getShareDialog(context);
                      }),
                      cardBottomButton(Icons.map, () {
                        albumuHaritadaGoster(album);
                      }),
                      cardBottomButton(
                          durum == 'Aktif'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off, () async {
                        albumAktifEt(album);
                      }),
                    ],
                  )),
            ]),
      ),
    );
  }

  List<Widget> createAlbumCards() {
    String isDark = 'dark';
    List<Widget> cards = [];
    for (int i = 0; i < filteredAlbumList.length; i++) {
      var album = filteredAlbumList[i];
      String aktifPasif = 'Pasif';
      if (album.id == aktifalbum) {
        aktifPasif = 'Aktif';
      } else {
        aktifPasif = 'Pasif';
      }
      Image image;
      if (album.image == '') {
        if (isDark == 'dark') {
          image = Image.asset('assets/images/album_dark.png');
        } else {
          image = Image.asset('assets/images/album_light.png');
        }
      } else {
        // image = new Image.file(imageFile);
        if (cardType == 'GFCard') {
          image = Image.file(
            File(album.image.toString()),
            fit: BoxFit.fitWidth,
          );
        } else {
          image = Image.file(File(album.image.toString()),
              fit: BoxFit.fill, width: context.dynamicWidth(4.1));
        }
      }

      if (cardType == 'GFCard') {
        Widget card = createCustomCards(album, aktifPasif, isDark);
        cards.add(card);
      } else {
        Card card = createCard(album, image, aktifPasif);
        cards.add(card);
      }
    }
    return cards;
  }

  void initState() {
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      getDialog();
    });*/

    getAlbumList();

    controller = TabController(length: 3, vsync: this, initialIndex: 0);

    controller.addListener(() {
      setState(() {
        aktifTabIndex = controller.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Album album = Album();
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        drawer: Container(
          width: 350,
          child: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(18)),
                    color: Color(0xff26334d),
                    image: DecorationImage(
                        image: NetworkImage(''), fit: BoxFit.cover),
                  ),
                  accountName: Text('onur kılıç'),
                  accountEmail: Text('simurgonur@gmail.com'),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network('', fit: BoxFit.cover),
                    ),
                  ),
                  /* onDetailsPressed: () {},
                    arrowColor: Colors.black,*/
                ),
                listMenuItems(Icons.event_note, "Albüm Oluştur", getDialog),

                // SizedBox(height: context.dynamicHeight(3)),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                            leading: Icon(FontAwesomeIcons.moon),
                            title: Text(
                              'Gece Modu',
                              style: TextStyle(fontSize: 18),
                            )),
                      ),
                      Consumer<SwitchModel>(
                          builder: (context, switchModel, child) {
                        return Switch(
                            value: switchModel.isSwitchControl, //tetikleyici
                            activeTrackColor: Colors.lightGreen,
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.black54,
                            inactiveThumbColor: Colors.black,
                            onChanged: (bool data) async {
                              if (data == true) {
                                MyLocal.setStringData('theme', 'light');
                              } else {
                                MyLocal.setStringData('theme', 'dark');
                              }

                              switchModel.switchChanged(data); // dinleyici
                            });
                      }),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: ListTile(
                              leading:
                                  Icon(FontAwesomeIcons.arrowRightFromBracket),
                              title: Text(
                                'Çıkış',
                                style: TextStyle(fontSize: 18),
                              )))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          title: getAppController(),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Material(
              color: Color(0xff202b40),
              child: TabBar(
                onTap: (tabindex) async {
                  if (tabindex == 1) {
                    controller.index = controller.previousIndex;
                    albumMedyalariniAc(aktifalbum);
                  }
                  if (tabindex == 2) {
                    controller.index = controller.previousIndex;
                    albumuHaritadaGoster(aktifAlbumItem);
                  }
                },
                labelStyle: TextStyle(fontSize: 14),
                unselectedLabelStyle: TextStyle(fontSize: 12),
                indicatorColor: Color(0xff0e91ce),
                controller: controller,
                labelColor: Color(0xff0e91ce),
                unselectedLabelColor: Color(0xff697a9b),
                tabs: [
                  Tab(
                    child: Text(
                      'Albümler',
                    ),
                    //icon: Icon(Icons.list_alt),
                  ),
                  Tab(
                    child: Text(
                      'Medya',
                    ),
                    //icon: Icon(Icons.media_bluetooth_off),
                  ),
                  Tab(
                    child: Text(
                      'Harita',
                    ),
                    //icon: Icon(Icons.map)
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
            controller: controller,
            physics: aktifTabIndex != 2
                ? BouncingScrollPhysics()
                : NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  APP_VM.getAramaKutusu(context, this, album),
                  Expanded(
                    child: cardType == 'GFCard'
                        ? GridView(
                            padding: EdgeInsets.all(12),
                            shrinkWrap: false,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            children: createAlbumCards(),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            scrollDirection: Axis.vertical,
                            children: createAlbumCards(),
                          ),
                  ),
                ],
              ),
              Medya(id: tiklananAlbum),
              Harita(id: tiklananAlbum, type: 'album') //xxx
            ]),
        bottomNavigationBar: BottomNavigationBar(
          key: scaffoldState,
          currentIndex: currentIndex,
          onTap: (index) async {
            if (index == 0) {
              return BottomSheetItems(
                  Icons.camera_alt_outlined,
                  'Fotoğraf Çek ve Yükle',
                  Icons.image_outlined,
                  'Galiriden Fotoğraf Yükle', (num) {
                switch (num) {
                  case 0:
                    {
                      pickImage(ImageSource.camera);
                      break;
                    }
                  case 1:
                    {
                      pickImage(ImageSource.gallery);
                      break;
                    }
                }
              });
            }
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          // iconSize: context.dynamicHeight(50),
          selectedFontSize: context.dynamicHeight(65),
          unselectedFontSize: context.dynamicHeight(75),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Fotoğraf Ekle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_camera_back),
              label: 'Video Ekle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Ses Ekle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wysiwyg),
              label: 'Yazı Ekle',
            ),
          ],
        ),
      ),
    );
  }

  Widget listMenuItems(IconData icon, String title, Function callback) {
    return ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        //trailing: Text(trailing),
        onTap: () {
          callback();
          //Navigator.pop(context);
        }
        //  Navigator.pushNamed(context, routeName);

        );
  }

  Future<void> BottomSheetItems(IconData icon, String title, IconData icon1,
      String title1, Function callback) {
    return showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    leading: Icon(icon),
                    title: Text(title),
                    onTap: () {
                      Navigator.pop(context);
                      callback(0);
                    }),
                ListTile(
                    leading: Icon(icon1),
                    title: Text(title1),
                    onTap: () async {
                      Navigator.pop(context);
                      callback(1);
                    }),
              ],
            ));
  }

  getDialog() {
    Navigator.pop(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),

          title: Text('Albüm Adı'),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          // content: Text('albüm adını giriniz'),
          actions: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: context.dynamicWidth(18),
                      right: context.dynamicWidth(18)),
                  child: TextField(
                    controller: albumNameController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    cursorColor: const Color(0xff80C783),
                    decoration: InputDecoration(
                      labelText: 'Albüm Adını Giriniz',
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    child: Text(
                      'İptal',
                      style: TextStyle(color: Color(0xffe55656), fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () async {
                          if (albumNameController.text != '') {
                            Navigator.pop(context);
                            String userString =
                                await MyLocal.getStringData('user');
                            dynamic user = json.decode(userString);
                            Album album = Album();
                            album.insertData(
                                albumNameController.text, user['uid']);
                            int lastId = await AlbumDataBase.insertAlbum(album);
                            album.id = lastId;
                            getAlbumList();
                          }
                        },
                        child: Text('Tamam',
                            style: TextStyle(
                                color: Color(0xff80C783), fontSize: 17))),
                  )
                ])
              ],
            )
          ],
        );
      },
    );
  }

  getAppController() {
    if (controller.index == 0) {
      return Text('Oluşturulmuş Albümler', style: TextStyle());
    } else {
      if (controller.index == 1) {
        return Text('Albümün Medyaları', style: TextStyle());
      } else {
        return Text('Albümün Haritası', style: TextStyle());
      }
    }
  }

  // aktif olan albümü silme
  deleteAAlbum(int album_id) async {
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
    if (aktifalbum == album_id) {
      int lastAlbumId = await AlbumDataBase.getLastAlbum();
      await MyLocal.setIntData('aktifalbum', lastAlbumId);
      SBBildirim.bilgi(
          '${silinenMediaSayisi} Adet medya öğesi ve ${silinenAlbumSayisi} adet, ${silinecekAlbum?.name} adlı albüm silindi. Son albüm tekrar aktif edilmiştir.');
    } else {
      SBBildirim.bilgi(
          '${silinenMediaSayisi} Adet medya öğesi ve ${silinenAlbumSayisi} adet, ${silinecekAlbum?.name} adlı albüm silindi.');
    }
    Loading.close();
    getAlbumList();
  }

  albumArama(String name) async {
    List<Album> filter = [];

    filter = albumList;
    if (name.isEmpty) {
      filteredAlbumList = filter;
    } else {
      filteredAlbumList = filter
          .where(
              (album) => album.name!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredAlbumList;
    });
  }
}
