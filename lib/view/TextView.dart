import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loko_media/view/app.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:provider/provider.dart';

import '../database/AlbumDataBase.dart';
import '../models/Album.dart';
import '../providers/MedyaProvider.dart';
import '../services/GPS.dart';
import '../services/Loader.dart';
import '../services/MyLocal.dart';
import '../services/utils.dart';
import '../view_model/folder_model.dart';

class TextView extends StatefulWidget {
  late int aktifTabIndex;
  late AppState model;

  TextView({required this.aktifTabIndex, required this.model});

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  TextEditingController _textTitleController = TextEditingController();
  TextEditingController _textController = TextEditingController();
  late MediaProvider _mediaProvider;
  File? textFile;
  String? filePath;
  // String? filePath;

  @override
  void initState() {
    // TODO: implement initState
    _mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textTitleController,
              keyboardType: TextInputType.text,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff1e2c49),
                  contentPadding: EdgeInsets.all(8),
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
                  // border: InputBorder.none,
                  /*focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xff017eba),
                  )),*/
                  labelText: 'Başlık ',
                  labelStyle: TextStyle(
                    color: Color(0xff017eba),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.text,
              cursorColor: Colors.white,
              textCapitalization: TextCapitalization.words,
              maxLines: 5,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff1e2c49),
                  contentPadding: EdgeInsets.all(8),
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
                  // border: InputBorder.none,
                  /* focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Color(0xff017eba),
                  )),*/
                  labelText: 'İçerik ',
                  labelStyle: TextStyle(
                    color: Color(0xff017eba),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 20,
            ),
            child: SizedBox(
              height: 40,
              width: context.dynamicWidth(1.2),
              child: ElevatedButton(
                  onPressed: () async {
                    filePath = await FolderModel.generateTextPath();
                    await textInsertFile(_textTitleController.text,
                        _textController.text, filePath!);
                    Navigator.of(context).pop;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff017eba),
                  ),
                  child: Text(
                    'Kaydet',
                    style: TextStyle(fontSize: 15),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Future textInsertFile(
    String title,
    String icerik,
    String filePath,
  ) async {
    try {
      if (filePath == null) return;
      if (filePath != null) {
        Loading.waiting('Notunuz Yükleniyor');
      }

      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');
      textFile = File(filePath);
      await textFile?.writeAsString(icerik);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      Medias dbText = new Medias(
        album_id: aktifAlbumId,
        name: title,
        miniName: '',
        path: textFile?.path,
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'txt',
      );
      dbText.insertData({});
      await AlbumDataBase.insertFile(dbText, '', (lastId) {
        dbText.id = lastId;
        widget.model.getAlbumList();
      });

      Loading.close();
      SBBildirim.bilgi('Notunuz Kaydedilmiştir');
      if (widget.aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbText);
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }
}
