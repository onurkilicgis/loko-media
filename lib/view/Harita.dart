import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';

class Harita extends StatefulWidget {
  //albüm ya da fotoğrafın id bilgisi
  final int id;
  //bu bir albüm mü yoksa dosya mı
  final String type;
  Harita({required this.id, required this.type});
  @override
  State<Harita> createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {
  List<Medias> items = [];
  bool loadData = false;
  late InAppWebViewController _controller;
  bool pageLoad = false;

  // darttaki bir veriyi web tarafına göndermek için hazırlanmıştır.
  sendToWeb(dynamic sendData) {
    if (pageLoad) {
      //ekstra olarak gönderim zamanını ekliyorum
      int time = DateTime.now().millisecondsSinceEpoch;
      sendData['time'] = time;
      // göndereceğim veriyi tringe çevirdim
      String jsonText = json.encode(sendData);
      // web tarafında çalışacak olan kodu hazırlıyorum
      String webDdata = 'GL.getToAndroid(\'$jsonText\');';
      // bu çalıştırma isteğini de burada gönderiyorum
      _controller.evaluateJavascript(source: webDdata);
    }
  }

  //kullanıcının görmek istediği tüm mediaları haritaya göndermek için hazırlayan kısım
  sendAllMedias() {
    List<dynamic> list = [];
    if (items.length > 0) {
      for (int i = 0; i < items.length; i++) {
        Medias item = items[i];
        dynamic part = {
          'id': item.id,
          'name': item.name,
          'album_id': item.album_id,
          'miniName': item.miniName,
          'fileType': item.fileType,
          'isPublic': item.isPublic,
          'url': item.url,
          'api_id': item.api_id,
          'date': item.date,
          'status': item.status,
          'latitude': item.latitude,
          'longitude': item.longitude,
          'altitude': item.altitude,
        };
        list.add(part);
      }
    }
    // hazırlanmış olan veriyi göndermek için kullanılıyor
    sendToWeb({'type': widget.type, 'data': list});
  }

  // eğer albümdeki tüm medialar gösterilmek isteniyorsa getFiles(album_id) kullanılıyor
  // eğer albumdeki sadece 1 media gösterilmek isteniyorsa getAFile(file_id) kullanılıyor
  // items harita gösterilecek her öğeyi içerinde barındırıyor minimum 1 olacak şekilde
  // loaddata ise bu listenin çekilip çekilmediğini bize belirtiyor.
  getMedias() async {
    List<Medias> itemList = [];
    int id = widget.id;
    String type = widget.type;
    if (type == 'album') {
      itemList = await AlbumDataBase.getFiles(id);
    }
    if (type == 'medias') {
      Medias item = await AlbumDataBase.getAFile(id);
      itemList.add(item);
    }
    setState(() {
      ///data/user/0/com.gislayer.lokomedia.loko_media/app_flutter/albums/album-4/image-1669223482898.jpg /data/user/0/com.gislayer.lokomedia.loko_media/app_flutter/albums/album-4/image-1669223474832.jpg
      items = itemList;
      loadData = true;
    });
  }

  @override
  void initState() {
    getMedias();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (items.length == 0) {
      return Container();
    } else {
      return Container(
        child: InAppWebView(
          initialUrlRequest:
              URLRequest(url: Uri.parse("http://localhost:1990")),
          onWebViewCreated: (InAppWebViewController controller) {
            print("onWebViewCreated");
            _controller = controller;
            // web ile dart arasında json string alışverişini yapan köprü
            controller.addJavaScriptHandler(
                handlerName: 'sendRequestFromWeb',
                callback: (webDenGelenText) {
                  // gelen stringi decode edip json'a çeviriyoruz
                  dynamic request = json.decode(webDenGelenText.toString());
                  // gelen veri hep ilk parametrede olduğunu bildiğimiz için sıfırıncı indise odaklanıyoruz. çünkü gelen veri orada
                  String type = request[0]['type'];
                  switch (type) {
                    case 'pageload':
                      {
                        setState(() {
                          pageLoad = true;
                          sendAllMedias();
                        });
                        break;
                      }
                  }
                });
          },
          onLoadStart: (controller, url) {
            print("onLoadStart");
            setState(() {
              // this.url = url.toString();
            });
          },
          onLoadStop: (controller, url) {
            print("onLoadStart");
          },
        ),
      );
    }
  }
}
