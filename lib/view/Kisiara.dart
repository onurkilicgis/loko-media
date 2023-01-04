import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  searchUser(String search)async{
    dynamic cevap =
        await API.postRequest('api/lokomedia/searchUser', {'search':search.toString()});

    setState(() {
      if(cevap['status']==true){
        kisiler = cevap['data'];
      }else{
        kisiler=[];
      }
    });
  }
  //

  cikart(dynamic user){
    Util.evetHayir(context, 'Takibi Bırakma',
        '${user['name']} adlı kişiyi takibi bırakmak ister misiniz?',
            (cevap) async {
          if (cevap == true) {
            //
            dynamic cevap = await API.postRequest('api/lokomedia/removeFriend', {'uid':user['id'].toString()});
            if(cevap['status']==true){
              SBBildirim.bilgi("${user['name']} adlı kişiyi artık takip etmiyorsunuz.");
              searchUser(_kisiNameController.text);
            }else{
              SBBildirim.uyari('${user['name']} adlı kişiyi zaten takip etmiyorsunuz.');
            }

          }
        });
  }
  iptal(dynamic user){
    Util.evetHayir(context, 'Takip İsteği İptal Etme',
        '${user['name']} adlı kişiye gönderdiğiniz takip isteğini iptal etmek ister misiniz?',
            (cevap) async {
          if (cevap == true) {
            //
            dynamic cevap = await API.postRequest('api/lokomedia/removeFriend', {'uid':user['id'].toString()});
            if(cevap['status']==true){
              SBBildirim.bilgi("${user['name']} adlı kişiye gönderilen takip isteği iptal edildi.");
              searchUser(_kisiNameController.text);
            }else{
              SBBildirim.uyari('${user['name']} adlı kişiye gönderilen takip isteği iptal edilemedi.');
            }

          }
        });
  }

  takipEt(dynamic user){
    Util.evetHayir(context, 'Kişi Takip Etme',
        '${user['name']} adlı kişiyi takip etmek istediğinize emin misiniz?',
            (cevap) async {
          if (cevap == true) {
            //
            dynamic cevap = await API.postRequest('api/lokomedia/addFriend', {'uid':user['id'].toString()});
            if(cevap['status']==true){
              SBBildirim.bilgi("${user['name']} adlı kişiye takip isteği gönderilmiştir. Lütfen kabul etmesini bekleyiniz.");
              searchUser(_kisiNameController.text);
            }else{
              SBBildirim.uyari('${user['name']} adlı kişiye daha önce istek göndermişsiniz. Lütfen kabul etmesini bekleyiniz.');
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
      appBar: AppBar(
        title: Text('Kişi Arama'),
      ),
      body: Column(
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
                fillColor: Color(0xff1e2c49),
                contentPadding: EdgeInsets.all(8),
                hintText: 'Kişi Ara : Ad Soyad, Mail... ',
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
                itemCount: kisiler.length,
                itemBuilder: (BuildContext context, int index){
                  String img = kisiler[index]['img'];
                  String name = kisiler[index]['name'];
                  bool isMyFriend = kisiler[index]['isMyFriend'];
                  bool isRequested = kisiler[index]['isRequested'];
                  TextButton button = TextButton(
                      onPressed: () {
                        takipEt(kisiler[index]);
                      },
                      child: Text('Takip Et',style: TextStyle(color:Color(
                          0xff8bc34a)),));
                  if(isMyFriend==true){
                    button = TextButton(
                        onPressed: () {
                          cikart(kisiler[index]);
                        },
                        child: Text('Çıkart',style: TextStyle(color:Color(
                            0xffffda15)),));
                  }
                  if(isRequested==true){
                    button = TextButton(
                        onPressed: () {
                          iptal(kisiler[index]);
                        },
                        child: Text('İptal Et',style: TextStyle(color:Color(
                            0xffff7373)),));
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(img,scale: 1),
                        ),
                        title: Text('${name}'),
                        trailing:button,
                      ),
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
