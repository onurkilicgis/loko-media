import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/services/utils.dart';
import 'package:loko_media/view/Medya.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

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

  List<Album> albumList = [];
  int aktifalbum = -1;

  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image.path);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = image.path.split('.');
      String extension = parts[parts.length - 1];
      String filename = 'image-' + now.toString() + '.' + extension;
      Uint8List bytes = imageTemporary.readAsBytesSync();
      String? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}', bytes, filename);
      Medias dbImage = new Medias(
        album_id: aktifAlbumId,
        name: filename,
        path: newPath,
        latitude: 0,
        longitude: 0,
        altitude: 0,
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
    List<Album> dbAlbums = await albumDataBase.getAlbums();
    int aktif_album_no = await MyLocal.getIntData('aktifalbum');
    setState(() {
      albumList = dbAlbums;
      aktifalbum = aktif_album_no;
    });
  }

  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  AuthService _authService = AuthService();

  List<GFCard> createAlbumCards() {
    String isDark = 'dark';
    List<GFCard> cards = [];
    for (int i = 0; i < albumList.length; i++) {
      var album = albumList[i];
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
        image = Image.asset('assets/images/album_dark.png');
      }

      GFCard card = GFCard(
        boxFit: BoxFit.contain,
        titlePosition: GFPosition.start,
        image: Image.asset(
          'assets/images/album_dark.png',
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        showImage: true,
        title: GFListTile(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14.0))),
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                    actions: [
                      Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Albümü Aktif Et'),
                            onTap: () async {
                              await MyLocal.setIntData('aktifalbum', album.id);
                              getAlbumList();

                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                              leading: Icon(Icons.list_alt),
                              title: Text('Albümün İçindekileri Listele'),
                              onTap: () {}),
                          ListTile(
                              leading: Icon(FontAwesomeIcons.mapLocation),
                              title: Text('Haritada Göster'),
                              onTap: () {}),
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
                            onTap: () {},
                          ),
                        ],
                      )
                    ],
                  );
                });
          },
          onTap: () async {
            await MyLocal.setIntData('aktifalbum', album.id);
            controller.index = 1;
            setState(() {
              aktifalbum = album.id!;
            });
          },
          title: Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Container(
              child: Text(
                album.name==null?'':album.name!+', Sayı:'+album.itemCount!.toString(),
                style: TextStyle(color: Color(0xffbecbe7), fontSize: 17),
              ),
            ),
          ),

          subTitle: Container(
            child: Column(
              children: [
                /*Padding(
                  padding: const EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                  ),
                  child: Text(
                    album.date ?? '',
                    style: TextStyle(
                      color: Color(0xffbecbe7),
                      fontSize: 15,
                    ),
                  ),
                ),*/
                /*Padding(
                  padding: const EdgeInsets.only(
                    top: 3,
                  ),
                  child: Text(
                    'Sayı : ' +
                        album.itemCount!.toString() +
                        ', Durum : ' +
                        aktifPasif,
                    style: TextStyle(
                      color: Color(0xffbecbe7),
                      fontSize: 14,
                    ),
                  ),
                )*/
              ],
            ),
          ),

          // subTitleText: album.date,
        ),
        //content: Text("Some quick example text to build on the card"),
        buttonBar: GFButtonBar(
          alignment: WrapAlignment.spaceEvenly,

          // crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(25),
              highlightColor: Colors.red.withOpacity(0.8),
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
                                  onPressed: () {},
                                  child: Text('Evet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xffe80b0b),
                                      ))),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Hayır',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xff80C783),
                                      )))
                            ],
                          )
                        ],
                      );
                    });
              },
              child: GFAvatar(
                size: context.dynamicWidth(13),
                backgroundColor: Color(0xff202b40),
                child: Icon(
                  Icons.delete,
                  color: Color(0xff017eba),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              hoverColor: Colors.red,
              highlightColor: Colors.red.withOpacity(0.8),
              //splashColor: Colors.deepPurple.withOpacity(0.5),
              onTap: getShareDialog,
              child: GFAvatar(
                size: context.dynamicWidth(13),
                backgroundColor: Color(0xff202b40),
                child: Icon(
                  Icons.share,
                  color: Color(0xff017eba),
                ),
              ),
            ),
            GFAvatar(
              size: context.dynamicWidth(13),
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.supervised_user_circle,
                color: Color(0xff017eba),
              ),
            ),
            GFAvatar(
              size: context.dynamicWidth(13),
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.map,
                color: Color(0xff017eba),
              ),
            ),
            GFAvatar(
              size: context.dynamicWidth(13),
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.list_alt,
                color: Color(0xff017eba),
              ),
            ),
          ],
        ),
      );

      cards.add(card);
    }
    return cards;
  }

  void initState() {
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      getDialog();
    });*/
    getAlbumList();
    controller = TabController(length: 3, vsync: this);

    controller.addListener(() {
      setState(() {});
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
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              centerTitle: true,
              floating: true,
              snap: true,
              toolbarHeight: 60,
              expandedHeight: context.dynamicHeight(6),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Color(0xff26334d),
                ),
              ),
              title: getAppController(),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(context.dynamicHeight(11)),
                child: Material(
                  color: Color(0xff202b40),
                  child: TabBar(
                    labelStyle: TextStyle(fontSize: context.dynamicHeight(50)),
                    unselectedLabelStyle:
                        TextStyle(fontSize: context.dynamicHeight(55)),
                    indicatorColor: Colors.deepPurple,
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
            )
          ],
          body: TabBarView(
              controller: controller,
              physics: BouncingScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: searchController,
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.center,
                                cursorColor: const Color(0xff80C783),
                                decoration: InputDecoration(
                                  labelText: 'Albüm Arama',
                                ),
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.search)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.list)),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.filter_alt)),
                        ],
                      ),
                      ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        scrollDirection: Axis.vertical,
                        children: createAlbumCards(),
                      ),
                    ],
                  ),
                ),
                Medya(id: aktifalbum),
                Harita()
              ]),
        ),
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
                            Album album = Album();

                            album.insertData(
                                albumNameController.text, 'asdasdasd');
                            await AlbumDataBase.insertAlbum(album, (lastId) {
                              album.id = lastId;
                              getAlbumList();
                            });
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

  getShareDialog() {
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

  getDeleteDialog() {}

  getAppController() {
    if (controller.index == 0) {
      return Text('Oluşturulmuş Albümler',
          style: Theme.of(context).textTheme.headlineSmall);
    } else {
      if (controller.index == 1) {
        return Text('Albümün Medyaları',
            style: Theme.of(context).textTheme.headlineSmall);
      } else {
        return Text('Albümün Haritası',
            style: Theme.of(context).textTheme.headlineSmall);
      }
    }
  }
}
