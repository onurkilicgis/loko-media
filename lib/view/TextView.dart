import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loko_media/view_model/layout.dart';

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

  TextView({required this.aktifTabIndex});

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  TextEditingController _textController = TextEditingController();
  TextEditingController textNameController = TextEditingController();
  late MediaProvider _mediaProvider;
  File? textFile;
  String? filePath;
  // String? filePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            controller: _textController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.white,
            textCapitalization: TextCapitalization.words,
            maxLines: 35,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xff1e2c49),
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
              /*focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),*/
              hintText: 'Not Giriniz.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                  onPressed: () {
                    getTextDialog();
                  },
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
    String name,
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
      // Directory text = Directory(filePath);
      filePath = await FolderModel.generateAudioPath();
      textFile = File(filePath);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = filePath.split('.');
      String extension = parts[parts.length - 1];

      String filename = 'text-' + now.toString() + '.' + extension;
      String miniFilename = 'text-' + now.toString() + '-mini.' + extension;
      Uint8List bytes = textFile!.readAsBytesSync();
      dynamic? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}',
          bytes,
          filename,
          miniFilename,
          'text');
      Medias dbText = new Medias(
        album_id: aktifAlbumId,
        name: name,
        miniName: '',
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'text',
      );
      dbText.insertData({'title': name, 'desc': _textController.text});
      await AlbumDataBase.insertFile(dbText, '', (lastId) {
        dbText.id = lastId;
      });
      Loading.close();
      if (widget.aktifTabIndex == 1) {
        _mediaProvider.addMedia(dbText);
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  getTextDialog() {
    Navigator.pop(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Not Kayıt'),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          actions: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: context.dynamicWidth(18),
                      right: context.dynamicWidth(18)),
                  child: TextField(
                    controller: textNameController,
                    keyboardType: TextInputType.text,
                    // textAlign: TextAlign.center,
                    cursorColor: Colors.white,

                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Ses Kayıt Adı Giriniz',
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    child: Text(
                      'İptal',
                      style: TextStyle(color: Color(0xffe55656), fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () async {
                          if (textNameController.text != '') {
                            Navigator.pop(context);
                            await textInsertFile(
                                textNameController.text, filePath!);
                            //MedyaState.audioCard();
                          }
                        },
                        child: Text('Tamam',
                            style: TextStyle(
                                color: Color(0xff80C783), fontSize: 17))),
                  )
                ])
              ],
            )
          ],
        );
      },
    );
  }
}
