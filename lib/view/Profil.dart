import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/API2.dart';

class Profil extends StatefulWidget {
  dynamic user;

  Profil({required this.user});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  dynamic item;
  bool pageLoad = false;

  getProfil() async {
    try {
      dynamic profil = await API.postRequest(
          'api/lokomedia/getProfile', {'user_id': widget.user['id']});

      if (profil['status'] == true) {
        item = profil['data'];

        setState(() {
          pageLoad = true;
        });
      }
    } catch (e) {
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(e.toString()),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    getProfil();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (pageLoad) {
      return Scaffold(
        backgroundColor: Theme.of(context).progressIndicatorTheme.color,
        appBar: AppBar(
            backgroundColor: Theme.of(context).progressIndicatorTheme.color,
            elevation: 0,
            title: Text('${item['user']['name']}'),
            centerTitle: true,
            actions: [
              item['isMyProfile'] == true
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          child: Icon(Icons.more_horiz),
                          onSelected: (value) {},
                          itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.person_remove_outlined,
                                      ),
                                      Text('a139'.tr),
                                    ],
                                  ),
                                  value: 1,
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.settings),
                                      Text('a140'.tr),
                                    ],
                                  ),
                                  value: 2,
                                )
                              ]),
                    )
                  : Container()
            ]),
        body: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 60, left: 100, right: 100, bottom: 20),
                child: CircleAvatar(
                  radius: 70.0,
                  backgroundImage: NetworkImage(item['user']['img']),
                  backgroundColor: Colors.transparent,
                )),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 25),
              child: Align(
                  alignment: Alignment.center,
                  child:
                      Opacity(opacity: 0.8, child: Text(item['user']['mail']))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      item['paylasim_sayisi'].toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          'a141'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(children: [
                  Text(
                    item['takipci_sayisi'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        'a142'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                ]),
                Column(children: [
                  Text(
                    item['takip_sayisi'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        '143'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                ]),
              ],
            ),
            item['isMyProfile'] == false
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('a124'.tr),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              'a144'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }
}
