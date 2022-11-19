import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/view_model/layout.dart';

class Medya extends StatefulWidget {
  int? id;

  Medya({this.id});

  @override
  State<Medya> createState() => _MedyaState();
}

class _MedyaState extends State<Medya> {
  List<Medias> fileList = [];

  getFileList(int album_id) async {
    List<Medias> file = await AlbumDataBase.getFiles(album_id);
    setState(() {
      fileList = file;
    });
  }

  @override
  void initState() {
    getFileList(widget.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: fileList.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: context.dynamicWidth(4),
          maxCrossAxisExtent: context.dynamicHeight(8),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Image.file(
              File(fileList[index].path.toString()),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
