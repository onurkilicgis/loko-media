import 'package:flutter/material.dart';

import '../models/Album.dart';
import '../services/API2.dart';
import '../services/utils.dart';

class Takipettiklerim extends StatefulWidget {
  const Takipettiklerim({Key? key}) : super(key: key);

  @override
  State<Takipettiklerim> createState() => _TakipettiklerimState();
}

class _TakipettiklerimState extends State<Takipettiklerim> {
  TextEditingController _kisiNameController = TextEditingController();
  late List<dynamic> takipciler = [];
  late List<dynamic> filtered = [];

  getYouFriends() async {
    //
    dynamic cevap = await API.postRequest('api/lokomedia/getMyFriends', {});

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
    Util.evetHayir(context, 'Takibi Bırakma',
        '${user['name']} adlı kişiyi takip etmeyi bırakmak ister misiniz?',
        (cevap) async {
      if (cevap == true) {
        //
        dynamic cevap = await API.postRequest(
            'api/lokomedia/removeFriend', {'uid': user['id'].toString()});
        if (cevap['status'] == true) {
          SBBildirim.bilgi(
              "${user['name']} adlı kişiyi artık takip etmiyorsunuz.");
          await getYouFriends();
        } else {
          SBBildirim.uyari(
              '${user['name']} adlı kişiyi zaten takip etmiyorsunuz.');
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getYouFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takip Ettiklerim : ${takipciler.length} Kişi'),
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
            Container(
              height: 500,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
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
                  }),
            )
          ],
        ),
      ),
    );
  }
}
