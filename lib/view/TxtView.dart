import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/services/utils.dart';
import '../view_model/folder_model.dart';
import '../models/Album.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io' as ioo;
class TxtView extends StatefulWidget {
  late bool appbarstatus;
  late Medias medias;
  String type;
  dynamic item;

  TxtView({required this.medias, required this.appbarstatus,required this.type,this.item});

  @override
  State<TxtView> createState() => _TxtViewState();
}

class _TxtViewState extends State<TxtView> {
  late ioo.File file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarstatus == true
          ? AppBar(
              title: Text(
                'a161'.tr,
                style: TextStyle(fontSize: 23),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: ListView(children: [
          FutureBuilder(
            future: readTxt(widget.medias),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 430,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Opacity(
                            opacity: 0.7,
                            child: Text(
                              'a162'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Slabo27px',
                                fontSize: 17,
                                color:
                                    Theme.of(context).listTileTheme.iconColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Opacity(
                            opacity: 0.8,
                            child: Text(
                              widget.medias.name!,
                              style: TextStyle(
                                  fontFamily: 'Slabo27px',
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Opacity(
                            opacity: 0.7,
                            child: Text(
                              'a163'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontFamily: 'Slabo27px',
                                fontSize: 17,
                                color:
                                    Theme.of(context).listTileTheme.iconColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Opacity(
                            opacity: 0.7,
                            child: Text(
                              '${snapshot.data}',
                              style: TextStyle(
                                  fontFamily: 'Slabo27px',
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ]),
      ),
    );
  }

  Future<String?> readTxt(Medias medias) async {
    try {
      if(widget.type=='url'){
        var response = await http.get(Uri.parse(medias.path!));
        List<int> bytes = response.bodyBytes;
        Uint8List buffer = Uint8List.fromList(bytes);
        String fakeFileName = widget.item['url'];
        String fakepath  = await FolderModel.getRootPath(fakeFileName);
        file  = new ioo.File(fakepath);
        file.writeAsBytesSync(buffer);
        final contents = await file.readAsString();
        return contents.toString();

      }else{
      final file = await File(medias.path!);

      final contents = await file.readAsString();

      return contents.toString();}
    } catch (e) {
      // If encountering an error, return 0
      SBBildirim.hata(e.toString());
    }
  }
}
