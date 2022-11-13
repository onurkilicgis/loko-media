import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/position/gf_position.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../view_model/main_view_models.dart';

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
  late Color boxColor;

  AlbumDataBase albumDataBase = AlbumDataBase();

  List<Album> albumList = [];

  getAlbumList() async {
    List<Album> dbAlbums = await albumDataBase.getAlbums();
    setState(() {
      albumList = dbAlbums;
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
          title: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Container(
              child: Text(
                album.name!,
                style: TextStyle(
                  color: Color(0xffbecbe7),
                ),
              ),
            ),
          ),

          subTitle: Container(
            child: Text(
              album.date!,
              style: TextStyle(
                color: Color(0xffbecbe7),
              ),
            ),
          ),

          // subTitleText: album.date,
        ),
        //content: Text("Some quick example text to build on the card"),
        buttonBar: GFButtonBar(
          alignment: WrapAlignment.spaceEvenly,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            GFAvatar(
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.delete,
                color: Color(0xff017eba),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              hoverColor: Colors.red,
              highlightColor: Colors.red.withOpacity(0.8),
              //splashColor: Colors.deepPurple.withOpacity(0.5),
              onTap: getShareDialog,
              child: GFAvatar(
                backgroundColor: Color(0xff202b40),
                child: Icon(
                  Icons.share,
                  color: Color(0xff017eba),
                ),
              ),
            ),
            GFAvatar(
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.supervised_user_circle,
                color: Color(0xff017eba),
              ),
            ),
            GFAvatar(
              backgroundColor: Color(0xff202b40),
              child: Icon(
                Icons.map,
                color: Color(0xff017eba),
              ),
            ),
            GFAvatar(
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
    controller = TabController(length: 2, vsync: this);

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
        appBar: AppBar(
          title: getAppController(),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(context.dynamicHeight(16)),
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
                    icon: Icon(Icons.list_alt),
                  ),
                  Tab(
                    child: Text(
                      'Medya',
                    ),
                    icon: Icon(Icons.media_bluetooth_off),
                  ),
                  Tab(
                      child: Text(
                        'Harita',
                      ),
                      icon: Icon(Icons.map)),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
            child: TabBarView(
                controller: controller,
                physics: BouncingScrollPhysics(),
                children: [
              ListView(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                children: createAlbumCards(),
              ),
              Container()
            ])),
        bottomNavigationBar: BottomNavigationBar(
          key: scaffoldState,
          currentIndex: currentIndex,
          onTap: (index) async {
            if (index == 0) {
              return BottomSheetItems(Icons.camera_alt, 'Fotoğraf Çek ve Yükle',
                  Icons.photo, 'Galiriden Fotoğraf Yükle', (num) {
                switch (num) {
                  case 0:
                    {
                      break;
                    }
                  case 1:
                    {
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
              icon: Icon(Icons.insert_drive_file_sharp),
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
          title: Text('Albüm Adı'),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          content: Text('albüm adını giriniz'),
          actions: [
            Column(
              children: [
                TextField(
                  controller: albumNameController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  cursorColor: const Color(0xff80C783),
                  decoration: InputDecoration(
                    hintText: 'yazınız',
                  ),
                  onChanged: (value) {},
                ),
                Row(children: [
                  ElevatedButton(
                    child: Text('tamam'),
                    onPressed: () async {
                      if (albumNameController.text != '') {
                        Navigator.pop(context);
                        Album album = Album();
                        album.insertData(albumNameController.text, 'asdasdasd');
                        await AlbumDataBase.insertAlbum(album, (lastId) {
                          album.id = lastId;
                          getAlbumList();
                        });
                      }
                    },
                  ),
                  ElevatedButton(onPressed: () {}, child: Text('iptal'))
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
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          // content: Text('albüm adını giriniz'),
          actions: [
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text('Herkesle paylaş'),
                  onTap: () {},
                ),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Bağlantıyı paylaş'),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Mail olarak gönder'),
                    onTap: () {}),
                ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Sosyal medyada paylaş'),
                    onTap: () {}),
              ],
            )
          ],
        );
      },
    );
  }

  getAppController() {
    if (controller.index == 0) {
      return Text('Size Ait Olan Projeler',
          style: Theme.of(context).textTheme.headlineSmall);
    } else {
      if (controller.index == 1) {
        return Text('Albüme Ait Medyalar',
            style: Theme.of(context).textTheme.headlineSmall);
      } else {
        return Text('Bağlı Olduğunuz Projeler',
            style: Theme.of(context).textTheme.headlineSmall);
      }
    }
  }
}
