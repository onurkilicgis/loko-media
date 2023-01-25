import 'package:flutter/material.dart';

import '../models/Album.dart';
import '../services/API2.dart';
import '../services/utils.dart';

class Takipcilerim extends StatefulWidget {
  const Takipcilerim({Key? key}) : super(key: key);

  @override
  State<Takipcilerim> createState() => _TakipcilerimState();
}

class _TakipcilerimState extends State<Takipcilerim> {
  TextEditingController _kisiNameController = TextEditingController();
  List<dynamic> takipciler = [];
  List<dynamic> filtered = [];

  getMyFriends() async {
    //
    dynamic cevap = await API.postRequest('api/lokomedia/getYouFriends', {});

    setState(() {
      if (cevap['status'] == true) {
        takipciler = cevap['data'];
        filtered = cevap['data'];
      } else {
        takipciler = [];
      }
    });
  }

  searchInList(String search) {
    List<dynamic> arr = [];
    for (int i = 0; i < takipciler.length; i++) {
      String name = takipciler[i]['name'];
      String mail = takipciler[i]['mail'];
      String search2 = search.toLowerCase();
      name = name.toLowerCase();
      mail = mail.toLowerCase();
      if (name.indexOf(search2) != -1 || mail.indexOf(search2) != -1) {
        arr.add(takipciler[i]);
      }
    }
    setState(() {
      filtered = arr;
    });
  }

  cikart(dynamic user) {
    Util.evetHayir(context, 'Takipçini Çıkarma',
        '${user['name']} adlı kişinin sizi takip etmesini istemiyor musunuz?',
        (cevap) async {
      if (cevap == true) {
        //
        dynamic cevap = await API.postRequest(
            'api/lokomedia/removeMe', {'uid': user['id'].toString()});
        if (cevap['status'] == true) {
          SBBildirim.bilgi(
              "${user['name']} adlı kişi sizi artık takip edemez.");
          await getMyFriends();
        } else {
          SBBildirim.uyari(
              '${user['name']} adlı kişi sizi zaten takip etmiyor.');
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takipçi Listem: ${takipciler.length} Kişi'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (name) async {
                  print(name);
                  searchInList(name);
                },
                controller: _kisiNameController,
                keyboardType: TextInputType.text,
                cursorColor: Colors.white,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff1e2c49),
                  contentPadding: EdgeInsets.all(8),
                  hintText: 'Listede Ara... ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: Color(0xff017eba),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff017eba),
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  String img = filtered[index]['img'];
                  String name = filtered[index]['name'];
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 0, left: 8, right: 8, bottom: 0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(img, scale: 1),
                        ),
                        title: Text('${name}'),
                        trailing: TextButton(
                            onPressed: () {
                              cikart(filtered[index]);
                            },
                            child: Text(
                              'Çıkart',
                              style: TextStyle(color: Color(0xffffda15)),
                            )),
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
