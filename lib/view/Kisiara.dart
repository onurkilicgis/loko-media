import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/Album.dart';
import '../services/API2.dart';
import '../services/utils.dart';

class Kisiara extends StatefulWidget {
  const Kisiara({Key? key}) : super(key: key);

  @override
  State<Kisiara> createState() => _KisiaraState();
}

class _KisiaraState extends State<Kisiara> {
  TextEditingController _kisiNameController = TextEditingController();
  late List<dynamic> kisiler = [];

  searchUser(String search) async {
    dynamic cevap = await API
        .postRequest('api/lokomedia/searchUser', {'search': search.toString()});

    setState(() {
      if (cevap['status'] == true) {
        kisiler = cevap['data'];
      } else {
        kisiler = [];
      }
    });
  }
  //

  cikart(dynamic user) {
    Util.evetHayir(context, 'a110'.tr,
        Utils.getComplexLanguage('a111'.tr, {'name': user['name']}),
        (cevap) async {
      if (cevap == true) {
        //
        dynamic cevap = await API.postRequest(
            'api/lokomedia/removeFriend', {'uid': user['id'].toString()});
        if (cevap['status'] == true) {
          SBBildirim.bilgi(
              Utils.getComplexLanguage('a112'.tr, {'name': user['name']}));
          searchUser(_kisiNameController.text);
        } else {
          SBBildirim.uyari(
            Utils.getComplexLanguage('a113'.tr, {'name': user['name']}),
          );
        }
      }
    });
  }

  iptal(dynamic user) {
    Util.evetHayir(context, 'a114'.tr,
        Utils.getComplexLanguage('a115'.tr, {'name': user['name']}),
        (cevap) async {
      if (cevap == true) {
        //
        dynamic cevap = await API.postRequest(
            'api/lokomedia/removeFriend', {'uid': user['id'].toString()});
        if (cevap['status'] == true) {
          SBBildirim.bilgi(
            Utils.getComplexLanguage('a116'.tr, {'name': user['name']}),
          );
          searchUser(_kisiNameController.text);
        } else {
          SBBildirim.uyari(
            Utils.getComplexLanguage('a117'.tr, {'name': user['name']}),
          );
        }
      }
    });
  }

  takipEt(dynamic user) {
    Util.evetHayir(context, 'a118'.tr,
        Utils.getComplexLanguage('a119'.tr, {'name': user['name']}),
        (cevap) async {
      if (cevap == true) {
        //
        dynamic cevap = await API.postRequest(
            'api/lokomedia/addFriend', {'uid': user['id'].toString()});
        if (cevap['status'] == true) {
          SBBildirim.bilgi(
            Utils.getComplexLanguage('a120'.tr, {'name': user['name']}),
          );
          searchUser(_kisiNameController.text);
        } else {
          SBBildirim.uyari(
            Utils.getComplexLanguage('a121'.tr, {'name': user['name']}),
          );
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('a122'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (name) async {
                  print(name);
                  searchUser(name);
                },
                controller: _kisiNameController,
                keyboardType: TextInputType.text,
                cursorColor: Colors.white,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).appBarTheme.backgroundColor,
                  contentPadding: EdgeInsets.all(8),
                  hintText: 'a123'.tr,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: Theme.of(context).listTileTheme.iconColor!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).listTileTheme.iconColor!,
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: kisiler.length,
                itemBuilder: (BuildContext context, int index) {
                  String img = kisiler[index]['img'];
                  String name = kisiler[index]['name'];
                  bool isMyFriend = kisiler[index]['isMyFriend'];
                  bool isRequested = kisiler[index]['isRequested'];
                  TextButton button = TextButton(
                      onPressed: () {
                        takipEt(kisiler[index]);
                      },
                      child: Text(
                        'a124'.tr,
                        style: TextStyle(color: Color(0xff8bc34a)),
                      ));
                  if (isMyFriend == true) {
                    button = TextButton(
                        onPressed: () {
                          cikart(kisiler[index]);
                        },
                        child: Text(
                          'a125'.tr,
                          style: TextStyle(color: Color(0xffffda15)),
                        ));
                  }
                  if (isRequested == true) {
                    button = TextButton(
                        onPressed: () {
                          iptal(kisiler[index]);
                        },
                        child: Text(
                          'a126'.tr,
                          style: TextStyle(color: Color(0xffff7373)),
                        ));
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 0, left: 8, right: 8, bottom: 0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(img, scale: 1),
                        ),
                        title: Text('${name}'),
                        trailing: button,
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
