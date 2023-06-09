import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/providers/SwitchProvider.dart';
import 'package:loko_media/services/GPS.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/services/utils.dart';
import 'package:loko_media/view/AudioRecorder.dart';
import 'package:loko_media/view/Kisiara.dart';
import 'package:loko_media/view/Medya.dart';
import 'package:loko_media/view/Paylasimlar.dart';
import 'package:loko_media/view/Takipcilerim.dart';
import 'package:loko_media/view_model/app_view_model.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../providers/MedyaProvider.dart';
import '../services/Loader.dart';
import '../services/auth.dart';
import '../view_model/folder_model.dart';
import 'Harita.dart';
import 'LoginPage.dart';
import 'Profil.dart';
import 'Takipettiklerim.dart';
import 'TextView.dart';

class App extends StatefulWidget {
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with SingleTickerProviderStateMixin {
  AuthService _authService = AuthService();
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
  dynamic user;
  bool userload = false;
  List<Album> deleteAlbum = [];

  Future<void> getUser() async {
    String userString = await MyLocal.getStringData('user');
    user = json.decode(userString);
    setState(() {
      userload = true;
    });
  }

  Future pickImage(ImageSource source) async {
    try {
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      } else {
        final image = await ImagePicker().pickImage(source: source);
        if (image == null) return;
        if (image != null) {
          Loading.waiting('a58'.tr);
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
        if (aktifTabIndex == 2) {
          _mediaProvider.addMedia(dbImage);
        }
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  Future pickVideo(ImageSource source, File? video) async {
    try {
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      } else {
        final video = await ImagePicker().pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 300),
        );
        if (video == null) {
          return;
        } else {
          Loading.waiting('a59'.tr);
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
        if (aktifTabIndex == 2) {
          _mediaProvider.addMedia(dbImage);
        }
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  getAlbumList() async {
    List<Album> dbAlbums = await AlbumDataBase.getAlbums();
    int aktif_album_no = await MyLocal.getIntData('aktifalbum');
    String cardType2 = await MyLocal.getStringData('card-type');
    if (dbAlbums.length > 0) {
      Album album =
          dbAlbums.firstWhere((element) => aktif_album_no == element.id);
      setState(() {
        albumList = dbAlbums;
        filteredAlbumList = dbAlbums;
        aktifalbum = aktif_album_no;
        cardType = cardType2;
        aktifAlbumItem = album;
      });
    } else {
      setState(() {
        albumList = dbAlbums;
        filteredAlbumList = dbAlbums;
        aktifalbum = aktif_album_no;
        cardType = cardType2;
      });
    }
  }

  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  Card createCard(album, image, durum, isDark) {
    return Card(
      child: ListTile(
        onTap: () {
          albumMedyalariniAc(album.id);
        },
        leading: image,
        title: Text(
          album.name,
          style: TextStyle(
            shadows: <Shadow>[
              isDark == 'dark'
                  ? Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 0.1,
                      color: Color.fromARGB(255, 0, 0, 0),
                    )
                  : Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 0.1,
                      color: Color.fromARGB(255, 255, 255, 255),
                    )
            ],
          ),
        ),
        subtitle: Text(
            Utils.getComplexLanguage(
                'a60'.tr, {'sayi': album.itemCount, 'durum': durum}),
            style: TextStyle(
              fontSize: 10,
              shadows: <Shadow>[
                isDark == 'dark'
                    ? Shadow(
                        offset: Offset(0.5, 0.5),
                        blurRadius: 0.1,
                        color: Color.fromARGB(255, 0, 0, 0),
                      )
                    : Shadow(
                        offset: Offset(0.5, 0.5),
                        blurRadius: 0.1,
                        color: Color.fromARGB(255, 255, 255, 255),
                      )
              ],
            )),
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
            color: Theme.of(context).primaryColor,
            shape: CircleBorder(),
          ),
          child: IconButton(
            iconSize: 16,
            icon: Icon(icon, color: Theme.of(context).listTileTheme.iconColor),
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
    SBBildirim.bilgi(Utils.getComplexLanguage('a61'.tr, {'name': album.name}));
    getAlbumList();
  }

  albumMedyalariniAc(int album_id) {
    setState(() {
      tiklananAlbum = album_id;
    });
    tabChange(2);
  }

  albumuHaritadaGoster(album) {
    if (album.itemCount > 0) {
      setState(() {
        tiklananAlbum = album.id;
      });
      tabChange(3);
    } else {
      SBBildirim.uyari('a62'.tr);
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
                              isDark == 'dark'
                                  ? Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 0.1,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    )
                                  : Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 0.1,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    )
                            ],
                          ),
                        ),
                      ),
                      Text(
                        Utils.getComplexLanguage('a60'.tr,
                            {'sayi': album.itemCount, 'durum': durum}),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10,
                          shadows: <Shadow>[
                            isDark == 'dark'
                                ? Shadow(
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 0.1,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  )
                                : Shadow(
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 0.1,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  )
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
                        APP_VM.getShareDialog(context, album);
                      }),
                      cardBottomButton(Icons.map, () {
                        albumuHaritadaGoster(album);
                      }),
                      cardBottomButton(
                          durum == 'a218'.tr
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

  List<Widget> createAlbumCards(themeStatus) {
    String isDark = themeStatus == true ? 'dark' : 'light';
    List<Widget> cards = [];
    for (int i = 0; i < filteredAlbumList.length; i++) {
      var album = filteredAlbumList[i];
      String aktifPasif = 'a217'.tr;
      if (album.id == aktifalbum) {
        aktifPasif = 'a218'.tr;
      } else {
        aktifPasif = 'a217'.tr;
      }
      Image image;
      if (album.image == '') {
        if (isDark == 'dark') {
          image = Image.asset(
            'assets/images/album_dark.png',
            fit: BoxFit.cover,
            width: 75,
            height: 75,
          );
        } else {
          image = Image.asset(
            'assets/images/album_light.png',
            fit: BoxFit.cover,
            width: 75,
            height: 75,
          );
        }
      } else {
        if (cardType == 'GFCard') {
          image = Image.file(
            File(album.image.toString()),
            fit: BoxFit.fitWidth,
          );
        } else {
          image = Image.file(
            File(album.image.toString()),
            fit: BoxFit.contain,
          );
        }
      }

      if (cardType == 'GFCard') {
        Widget card = createCustomCards(album, aktifPasif, isDark);
        cards.add(card);
      } else {
        Card card = createCard(album, image, aktifPasif, isDark);
        cards.add(card);
      }
    }
    return cards;
  }

  late MediaProvider _mediaProvider;

  void initState() {
    getUser();

    _mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    getAlbumList();

    controller = TabController(length: 4, vsync: this, initialIndex: 0);

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

  openPage(String pagename) {
    switch (pagename) {
      case 'takipciler':
        {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Takipcilerim()));
          break;
        }
      case 'takipettiklerim':
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Takipettiklerim()));
          break;
        }
      case 'kisiara':
        {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Kisiara()));
          break;
        }
      case 'profil':
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Profil(user: user)));
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

    return userload == false
        ? Container()
        : DefaultTabController(
            length: 4,
            initialIndex: 0,
            child: WillPopScope(
              onWillPop: () {
                return Util.evetHayir(context, 'a64'.tr, 'a231'.tr,
                    (cevap) async {
                  if (cevap == true) {
                    await _authService.signOut();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  } else {
                    return false;
                  }
                });
              },
              child: Scaffold(
                drawer: Container(
                  width: 300,
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
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(18)),
                            color:
                                Theme.of(context).drawerTheme.backgroundColor,
                          ),
                          accountName: Text(user['name']),
                          accountEmail: Text(user['mail']),
                          currentAccountPicture: CircleAvatar(
                            child: ClipOval(
                              child:
                                  Image.network(user['img'], fit: BoxFit.cover),
                            ),
                          ),
                          /* onDetailsPressed: () {},
                      arrowColor: Colors.black,*/
                        ),
                        listMenuItems(Icons.person, "a219".tr, () {
                          openPage('profil');
                        }),
                        listMenuItems(Icons.event_note, "a220".tr, getDialog),
                        listMenuItems(Icons.search, "a221".tr, () {
                          openPage('kisiara');
                        }),
                        listMenuItems(Icons.supervised_user_circle, "a222".tr,
                            () {
                          openPage('takipciler');
                        }),
                        listMenuItems(
                            Icons.supervisor_account_rounded, "a223".tr, () {
                          openPage('takipettiklerim');
                        }),

                        // SizedBox(height: context.dynamicHeight(3)),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.moon,
                                  color:
                                      Theme.of(context).listTileTheme.iconColor,
                                ),
                                title: Text(
                                  'a63'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Consumer<SwitchModel>(
                                    builder: (context, switchModel, child) {
                                  return Switch(
                                      value: switchModel.isSwitchControl,
                                      //tetikleyici

                                      activeTrackColor: Color(0XFF79D6FD),
                                      activeColor: Theme.of(context)
                                          .listTileTheme
                                          .iconColor,
                                      inactiveTrackColor: Colors.grey,
                                      // inactiveThumbColor: Colors.black,
                                      onChanged: (bool data) async {
                                        if (data == true) {
                                          await MyLocal.setStringData(
                                              'theme', 'dark');
                                        } else {
                                          await MyLocal.setStringData(
                                              'theme', 'light');
                                        }

                                        switchModel
                                            .switchChanged(data); // dinleyici
                                      });
                                }),
                              ))
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.arrowRightFromBracket,
                                  color:
                                      Theme.of(context).listTileTheme.iconColor,
                                ),
                                title: Text(
                                  'a64'.tr,
                                  style: TextStyle(fontSize: 14),
                                ),
                                onTap: () async {
                                  await _authService.signOut();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                                },
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                appBar: AppBar(
                  centerTitle: true,
                  title: getAppController(),
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  foregroundColor:
                      Theme.of(context).appBarTheme.foregroundColor,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Material(
                      color: Theme.of(context).primaryColor,
                      child: TabBar(
                        onTap: (tabindex) async {
                          if (tabindex == 1) {
                            getAlbumList();
                          }
                          if (tabindex == 2) {
                            controller.index = controller.previousIndex;
                            albumMedyalariniAc(aktifalbum);
                          }
                          if (tabindex == 3) {
                            controller.index = controller.previousIndex;
                            albumuHaritadaGoster(aktifAlbumItem);
                          }
                        },
                        labelStyle: TextStyle(fontSize: 14),
                        unselectedLabelStyle: TextStyle(fontSize: 12),
                        indicatorColor: Theme.of(context).accentColor,
                        controller: controller,
                        labelColor: Theme.of(context).tabBarTheme.labelColor,
                        unselectedLabelColor:
                            Theme.of(context).tabBarTheme.unselectedLabelColor,
                        tabs: [
                          Tab(
                            child: Text(
                              'a65'.tr,
                            ),
                            //icon: Icon(Icons.list_alt),
                          ),
                          Tab(
                            child: Text(
                              'a66'.tr,
                            ),
                            //icon: Icon(Icons.list_alt),
                          ),
                          Tab(
                            child: Text(
                              'a67'.tr,
                            ),
                            //icon: Icon(Icons.media_bluetooth_off),
                          ),
                          Tab(
                            child: Text(
                              'a68'.tr,
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
                    physics: NeverScrollableScrollPhysics(),
                    /*physics: aktifTabIndex != 3
                        ? BouncingScrollPhysics()
                        : NeverScrollableScrollPhysics(),*/
                    children: [
                      Paylasimlar(id: tiklananAlbum),
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            APP_VM.getAramaKutusu(
                              context,
                              this,
                              album,
                            ),
                            Consumer<SwitchModel>(
                                builder: (context, switchModel, child) {
                              return Expanded(
                                child: cardType == 'GFCard'
                                    ? GridView(
                                        padding: EdgeInsets.all(12),
                                        shrinkWrap: false,
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        children: createAlbumCards(
                                            switchModel.isSwitchControl))
                                    : ListView(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(8),
                                        scrollDirection: Axis.vertical,
                                        children: createAlbumCards(
                                            switchModel.isSwitchControl),
                                      ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Container(
                        color: Theme.of(context).backgroundColor,
                        child: Medya(
                          id: tiklananAlbum,
                        ),
                      ),
                      Harita(id: tiklananAlbum, type: 'album')
                    ]),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  selectedItemColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                  unselectedItemColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
                  key: scaffoldState,
                  currentIndex: currentIndex,
                  onTap: (index) async {
                    if (index == 0) {
                      return BottomSheetItems(Icons.camera_alt_outlined,
                          'a69'.tr, Icons.image_outlined, 'a70'.tr, (num) {
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
                      return BottomSheetItems(Icons.video_camera_back, 'a71'.tr,
                          Icons.video_collection, 'a72'.tr, (num) {
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
                      return BottomSheetItems(
                          Icons.mic, 'a73'.tr, Icons.audio_file, 'a74'.tr,
                          (num) async {
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
                          'a75'.tr,
                          Icons.insert_drive_file_rounded,
                          'a76'.tr, (num) async {
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
                      label: 'a77'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.video_camera_back),
                      label: 'a78'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.mic),
                      label: 'a79'.tr,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.wysiwyg),
                      label: 'a80'.tr,
                    ),
                  ],
                ),
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
        leading: Icon(icon, color: Theme.of(context).listTileTheme.iconColor),
        title: Text(title,
            style: TextStyle(
              fontSize: 14,
            )),
        onTap: () {
          callback();
        });
  }

  Future<void> BottomSheetItems(IconData icon, String title, IconData icon1,
      String title1, Function callback) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).cardColor,
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
    albumNameController.text = '';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('a81'.tr),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
                    cursorColor: Theme.of(context).textTheme.headline5!.color,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .color!)),
                        // labelStyle: TextStyle(color: Colors.white),
                        labelText: 'a82'.tr,
                        labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.headline5!.color)),
                    onChanged: (value) {},
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    child: Text(
                      'a83'.tr,
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
                                albumNameController.text, user['id']);
                            int lastId = await AlbumDataBase.insertAlbum(album);
                            album.id = lastId;
                            getAlbumList();
                          }
                        },
                        child: Text('a84'.tr,
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
    switch (controller.index) {
      case 0:
        {
          return Text('a85'.tr, style: TextStyle());
        }

      case 1:
        {
          return Text('a86'.tr, style: TextStyle());
        }

      case 2:
        {
          return Text('a87'.tr, style: TextStyle());
        }

      case 3:
        {
          return Text('a88'.tr, style: TextStyle());
        }
    }
  }

  // aktif olan albümü silme
  deleteAAlbum(int album_id) async {
    Album? silinecekAlbum = await AlbumDataBase.getAAlbum(album_id);
    Loading.waiting(
        Utils.getComplexLanguage('a89'.tr, {'name': silinecekAlbum?.name}));
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
      SBBildirim.bilgi(Utils.getComplexLanguage('a90'.tr, {
        'medyasayi': silinenMediaSayisi,
        'albumsayi': silinenAlbumSayisi,
        'name': silinecekAlbum?.name
      }));
    } else {
      SBBildirim.bilgi(Utils.getComplexLanguage('a91'.tr, {
        'medyasayi': silinenMediaSayisi,
        'albumsayi': silinenAlbumSayisi,
        'name': silinecekAlbum?.name
      }));
    }

    getAlbumList();

    Loading.close();
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
    try {
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3', 'wav', 'm4a', 'ogv'],
        );
        if (result != null) {
          fileName = result.files.first.name;
          // Uint8List? bytes = result.files.first.bytes;
          pickedFile = result.files.first;

          audioFile = File(pickedFile!.path!);

          Loading.waiting('a92'.tr);

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
            name: fileName,
            miniName: '',
            path: newPath['file'],
            latitude: positions['latitude'],
            longitude: positions['longitude'],
            altitude: positions['altitude'],
            fileType: 'audio',
          );
          final player = FlutterSoundPlayer();
          player.openPlayer();
          Duration? duration =
              await player.startPlayer(fromURI: newPath['file']);
          dbAudio.insertData({'duration': duration?.inMilliseconds});
          player.closePlayer();
          await AlbumDataBase.insertFile(dbAudio, '', (lastId) {
            dbAudio.id = lastId;
            getAlbumList();
          });

          Loading.close();
          if (aktifTabIndex == 2) {
            _mediaProvider.addMedia(dbAudio);
          }
        } else {
          return null;
        }
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  textFilePicker() async {
    try {
      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      } else {
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

          Loading.waiting('a93'.tr);

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
              'albums/album-${aktifAlbumId}',
              bytes,
              filename,
              miniFilename,
              'txt');

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
          SBBildirim.bilgi('a94'.tr);
          if (aktifTabIndex == 2) {
            _mediaProvider.addMedia(dbText);
          }
        } else {
          return null;
        }
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }
}
