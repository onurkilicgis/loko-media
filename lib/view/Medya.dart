import 'dart:io' as ioo;

import 'package:flutter/material.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Medya extends StatefulWidget {
  int? id;
  final PageController pageController;
  final int index;

  Medya({this.id, this.index = 0})
      : pageController = PageController(initialPage: index);

  @override
  State<Medya> createState() => MedyaState();
}

class MedyaState extends State<Medya> {
  List<Medias> fileList = [];
  late int index = widget.index;

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
  void dispose() {
    super.dispose();
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
          return InkWell(
            onTap: openGallery,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                ioo.File(fileList[0].path.toString()),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  openGallery() {
    return PhotoViewGallery.builder(
        pageController: widget.pageController,
        scrollDirection: Axis.vertical,
        itemCount: fileList.length,
        scrollPhysics: BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
              imageProvider:
                  FileImage(ioo.File(fileList[index].path.toString())),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4);
        },
        onPageChanged: (index) => setState(() {
              this.index = index;
            }));
  }
}
