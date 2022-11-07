import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../view_model/main_view_models.dart';

class App extends StatefulWidget {
  // final VoidCallback function;
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> with SingleTickerProviderStateMixin {
  late TabController controller;

  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  AuthService _authService = AuthService();

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getApiCompany();
    });
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
      length: 2,
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
                listMenuItems(
                    Icons.event_note, "Bildirimlerim", "/notifications"),
                listMenuItems(
                    Icons.event_note, "Çalışmalarım", "/notifications"),
                listMenuItems(Icons.event_note, "Görevlerim", "/notifications"),
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
                            onChanged: (bool data) {
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
          title: controller.index == 0
              ? Text('Size Ait Olan Projeler',
                  style: Theme.of(context).textTheme.headlineSmall)
              : Text('Bağlı Olduğunuz Projeler',
                  style: Theme.of(context).textTheme.headlineSmall),
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
                labelColor: Color(0xff80C783),
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
                        'Albüm Haritası',
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
          children: [],
        )),
        bottomNavigationBar: BottomNavigationBar(
          key: scaffoldState,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) {
              // return BottomSheetItems(icon, title, function);
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
              icon: Icon(Icons.mic),
              label: 'Ses Kaydet ve Yükle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_camera_back),
              label: 'Video Kaydet ve Yükle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Fotoğraf Çek ve Yükle',
            ),
          ],
        ),
      ),
    );
  }

  Widget listMenuItems(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )),
      //trailing: Text(trailing),
      onTap: () {
        //  Navigator.pushNamed(context, routeName);
        setState(() {});
      },
    );
  }

  Future<dynamic> BottomSheetItems(
      IconData icon, String title, Function function) {
    return showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        builder: (context) => ListTile(
            leading: Icon(icon),
            title: Text(title),
            onTap: () {
              function;
            }));
  }
}
