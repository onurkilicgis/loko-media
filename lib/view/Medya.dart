import 'dart:io' as ioo;

import 'package:flutter/material.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:loko_media/view_model/media_view_model.dart';

import 'PhotoViewer.dart';

class Medya extends StatefulWidget {
  int? id;
  // final PageController pageController;
  // final int index;

  Medya({
    this.id,
    /*this.index = 0*/
  });
  // : pageController = PageController(initialPage: index);

  @override
  State<Medya> createState() => MedyaState();
}

class MedyaState extends State<Medya> {
  List<Medias> fileList = [];

  List<int> selectedMedias = [];
  bool selectionMode = false;

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

  // Media Seçme İşlemi Burada Yapılıyor
  selectMedia(Medias media) {
    // seçilmek istenen bu medya daha önce seçilmiş mi kontrol ediyor
    // indexOf -> dizi içerisinde aranan bir değerin index sırasını verir
    // en baştaki 0 dır , eğer listede yoksa -1 döner
    int index = selectedMedias.indexOf(media.id!);
    if (index == -1) {
      // daha önce seçilmediği için seçilenler içerisine ekleniyor
      selectedMedias.add(media.id!);
    } else {
      // zaten seçilmiş olan bir mediyayı tekrar pasif eder. seçimi kaldırır
      selectedMedias.removeAt(index);
    }
    // eğer hiç seçili öğe yoksa selectionModu false yapar
    // en az bir öğe seçilmiş ise selection mod'u true yapar.
    if (selectedMedias.length > 0) {
      selectionMode = true;
    } else {
      selectionMode = false;
    }
    setState(() {
      selectedMedias;
      selectionMode;
    });
  }

  imageCard(Medias) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        ioo.File(Medias.path.toString()),
        fit: BoxFit.cover,
      ),
    );
  }

  mediaCardBuilder(Medias) {
    Widget? media;
    bool secilimi = selectedMedias.indexOf(Medias.id) == -1 ? false : true;
    var secimIcon = secilimi == true
        ? Icons.check_box_outlined
        : Icons.check_box_outline_blank;
    double margin = secilimi == true ? 8 : 4;
    switch (Medias.fileType) {
      case 'image':
        {
          media = imageCard(Medias);
          break;
        }
      case 'video':
        {
          break;
        }
      case 'audio':
        {
          break;
        }
      case 'txt':
        {
          break;
        }
    }
    return InkWell(
      onTap: () {
        if (selectionMode == true) {
          selectMedia(Medias);
        } else {
          switch (Medias.fileType) {
            case 'image':
              {
                openGallery(Medias.path.toString(), Medias.name);
                break;
              }
          }
        }
      },
      onLongPress: () {
        Media_VM.openMediaLongPDialog(context, this, Medias);
      },
      child: Container(
        margin: EdgeInsets.all(margin),
        child: Stack(
          children: [
            media!,
            Padding(
              padding: const EdgeInsets.all(2),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  height: 32,
                  width: 32,
                  child: IconButton(
                    iconSize: 16,
                    icon: Icon(secimIcon, color: Color(0xff017eba)),
                    color: Colors.white,
                    onPressed: () {
                      selectMedia(Medias);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          return mediaCardBuilder(fileList[index]);
        },
      ),
    );
  }

  openGallery(path, name) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhotoViewer(imagePath: path, name: name)));
  }
}
