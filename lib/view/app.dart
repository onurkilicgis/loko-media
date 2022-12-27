import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/providers/SwitchProvider.dart';
import 'package:loko_media/services/GPS.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/services/utils.dart';
import 'package:loko_media/view/AudioRecorder.dart';
import 'package:loko_media/view/Medya.dart';
import 'package:loko_media/view_model/app_view_model.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../providers/MedyaProvider.dart';
import '../services/Loader.dart';
import '../services/auth.dart';
import '../view_model/folder_model.dart';
import 'Harita.dart';
import 'TextView.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with SingleTickerProviderStateMixin {
  late TabController controller;
  TextEditingController albumNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  late Color boxColor;
  File? audioFile;
  File? textFile;
  String? fileName;
  PlatformFile? pickedFile;
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
  File? video;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      if (image != null) {
        Loading.waiting('Çektiğiniz Fotoğraf Yükleniyor');
      }

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
      String miniFilename = 'image-' + now.toString() + '-mini.' + extension;
      Uint8List bytes = imageTemporary.readAsBytesSync();
      dynamic? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}',
          bytes,
          filename,
          miniFilename,
          'image');
      Medias dbImage = new Medias(
        album_id: aktifAlbumId,
        name: filename,
        miniName: miniFilename,
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'image',
      );
      dbImage.insertData({});
      await AlbumDataBase.insertFile(dbImage, newPath['mini'], (lastId) {
        dbImage.id = lastId;
        getAlbumList();
      });
      Loading.close();
      if (aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbImage);
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  Future pickVideo(ImageSource source, File? video) async {
    try {
      final video = await ImagePicker().pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 300),
      );
      if (video == null) {
        return;
      } else {
        Loading.waiting('Çektiğiniz Video Yükleniyor');
      }

      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');
      final imageTemporary = File(video.path);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = video.path.split('.');
      String extension = parts[parts.length - 1];
      String filename = 'video-' + now.toString() + '.' + extension;
      String miniFilename = 'video-' + now.toString() + '-mini.png';
      Uint8List bytes = imageTemporary.readAsBytesSync();
      dynamic? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}',
          bytes,
          filename,
          miniFilename,
          'video');
      Medias dbImage = new Medias(
        album_id: aktifAlbumId,
        name: filename,
        miniName: miniFilename,
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'video',
      );
      dbImage.insertData({});
      await AlbumDataBase.insertFile(dbImage, newPath['mini'], (lastId) {
        dbImage.id = lastId;
        getAlbumList();
      });
      Loading.close();
      if (aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbImage);
      }
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
        subtitle: Text('Öğe Sayısı : ${album.itemCount} Durum : ${durum}'),
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

  late MediaProvider _mediaProvider;

  void initState() {
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      getDialog();
    });*/

    _mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    getAlbumList();

    controller = TabController(length: 3, vsync: this, initialIndex: 0);

    controller.addListener(() {
      setState(() {
        aktifTabIndex = controller.index;
      });
    });
    super.initState();
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    String? q = uri?.query.toString();
    switch (q) {
      case 'photo':
        {
          pickImage(ImageSource.camera);
          break;
        }
      case 'video':
        {
          pickVideo(ImageSource.camera, video);
          break;
        }
      case 'audio':
        {
          buildPushAudio(context, this);
          break;
        }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
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
                                await MyLocal.setStringData('theme', 'light');
                              } else {
                                await MyLocal.setStringData('theme', 'dark');
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
            ;
            if (index == 1) {
              return BottomSheetItems(
                  Icons.video_camera_back,
                  'Video Kaydet ve Yükle',
                  Icons.video_collection,
                  'Galiriden Video Yükle', (num) {
                switch (num) {
                  case 0:
                    {
                      pickVideo(ImageSource.camera, video);
                      break;
                    }
                  case 1:
                    {
                      pickVideo(ImageSource.gallery, video);
                      break;
                    }
                }
              });
            }
            ;
            if (index == 2) {
              return BottomSheetItems(Icons.mic, 'Anlık Ses Kaydet ve Yükle',
                  Icons.audio_file, 'Mevcut Bir Ses Kaydını Ekle', (num) async {
                switch (num) {
                  case 0:
                    {
                      buildPushAudio(context, this);
                      break;
                    }
                  case 1:
                    {
                      await audioFilePicker();
                      break;
                    }
                }
              });
            }
            ;
            if (index == 3) {
              return BottomSheetItems(
                  Icons.text_snippet_sharp,
                  'Not Yaz Ve Kaydet',
                  Icons.insert_drive_file_rounded,
                  'Mevcut Bir Text Dosyası Yükle', (num) async {
                switch (num) {
                  case 0:
                    {
                      buildPushText(context, this);

                      break;
                    }
                  case 1:
                    {
                      await textFilePicker();
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

  Future<dynamic> buildPushAudio(BuildContext context, AppState model) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AudioRecorder(aktifTabIndex: aktifTabIndex, model: model)));
  }

  Future<dynamic> buildPushText(BuildContext context, AppState model) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TextView(
                  aktifTabIndex: aktifTabIndex,
                  model: model,
                )));
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
                    // textAlign: TextAlign.center,
                    cursorColor: Colors.white,

                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      labelStyle: TextStyle(color: Colors.white),
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

  audioFilePicker() async {
    // Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogv'],
    );
    if (result != null) {
      fileName = result.files.first.name;
      // Uint8List? bytes = result.files.first.bytes;
      pickedFile = result.files.first;

      audioFile = File(pickedFile!.path!);
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      Loading.waiting('Seçtiğiniz Ses Dosyası Yükleniyor...');

      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');

      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = audioFile!.path.split('.');
      String extension = parts[parts.length - 1];
      String filename = 'audio-' + now.toString() + '.' + extension;
      //String miniFilename = 'audio-' + now.toString() + '-mini.' + extension;
      // dosyaları byte tipinde okur. byte içerisinde integerlar bulunan bir dizidir.
      Uint8List bytes = audioFile!.readAsBytesSync();
      dynamic? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}', bytes, filename, '', 'audio');
      Medias dbAudio = new Medias(
        album_id: aktifAlbumId,
        name: filename,
        miniName: '',
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'audio',
      );
      final player = FlutterSoundPlayer();
      player.openPlayer();
      Duration? duration = await player.startPlayer(fromURI: newPath['file']);
      dbAudio.insertData({'duration': duration?.inMilliseconds});
      player.closePlayer();
      await AlbumDataBase.insertFile(dbAudio, '', (lastId) {
        dbAudio.id = lastId;
        getAlbumList();
      });

      Loading.close();
      if (aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbAudio);
      }
    } else {
      return null;
    }
  }

  textFilePicker() async {
    // Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
        'pdf',
      ],
    );
    if (result != null) {
      fileName = result.files.first.name;
      pickedFile = result.files.first;

      final textFile2 = File(pickedFile!.path!);
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      Loading.waiting('Seçtiğiniz Yazı Dosyası Yükleniyor...');

      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');

      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = textFile2.path.split('.');
      String extension = parts[parts.length - 1];
      extension = extension.toLowerCase();
      String filename = extension + '-' + now.toString() + '.' + extension;
      String miniFilename = '';
      Uint8List bytes = textFile2.readAsBytesSync();
      dynamic newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}', bytes, filename, miniFilename, 'txt');

      Medias dbText = new Medias(
        album_id: aktifAlbumId,
        name: fileName,
        miniName: '',
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'txt',
      );

      dbText.insertData({'type': extension});

      await AlbumDataBase.insertFile(dbText, '', (lastId) {
        dbText.id = lastId;
        getAlbumList();
      });

      Loading.close();
      SBBildirim.bilgi('Mevcut Dosyanız Yüklendi');
      if (aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbText);
      }
    } else {
      return null;
    }
  }
}
