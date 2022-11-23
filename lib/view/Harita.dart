import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:loko_media/models/Album.dart';
//import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Harita extends StatefulWidget {
  final int id;
  final String type;
  Harita({required this.id,required this.type});
  @override
  State<Harita> createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {

  List<Medias> items  = [];
  bool loadData = false;
  late InAppWebViewController _controller;
  bool pageLoad = false;

  sendToWeb(dynamic sendData) {
    if (pageLoad) {
      int time = DateTime.now().millisecondsSinceEpoch;
      sendData['time'] = time;
      String jsonText = json.encode(sendData);
      String webDdata = 'GL.getToAndroid(\'$jsonText\');';
      _controller.evaluateJavascript(source: webDdata);
    }
  }

  sendAllMedias(){
    List<dynamic> list = [];
    if(items.length>0){
      for(int i=0;i<items.length;i++){
        Medias item = items[i];
        dynamic part = {
          'id':item.id,
          'name':item.name,
          'album_id':item.album_id,
          'miniName':item.miniName,
          'fileType':item.fileType,
          'isPublic':item.isPublic,
          'url':item.url,
          'api_id':item.api_id,
          'date':item.date,
          'status':item.status,
          'latitude':item.latitude,
          'longitude':item.longitude,
          'altitude':item.altitude,
        };
        list.add(part);
      }
    }
    sendToWeb({
      'type':widget.type,
      'data':list
    });
  }

  getMedias()async{
    List<Medias> itemList = [];
    int id = widget.id;
    String type = widget.type;
    if(type=='album'){
      itemList = await AlbumDataBase.getFiles(id);
    }
    if(type=='medias'){
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
    if(items.length==0){
      return Container();
    }else{
      return Container(
        child: InAppWebView(
          initialUrlRequest:
          URLRequest(url: Uri.parse("http://localhost:1990")),
          onWebViewCreated: (InAppWebViewController controller) {
            print("onWebViewCreated");
            _controller = controller;
            controller.addJavaScriptHandler(
                handlerName: 'sendRequestFromWeb',
                callback: (webDenGelenText) {
                  dynamic request = json.decode(webDenGelenText.toString());
                  String type = request[0]['type'];
                  switch (type) {
                    case 'pageload':{
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
