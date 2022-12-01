import 'dart:io' as ioo;

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/models/Album.dart';
import 'package:loko_media/services/utils.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:loko_media/view_model/media_view_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Medya extends StatefulWidget {
  int? id;
  final PageController pageController;
  late int index;

  Medya({this.id, this.index = 0})
      : pageController = PageController(initialPage: index);

  @override
  State<Medya> createState() => MedyaState();
}

class MedyaState extends State<Medya> {
  List<Medias> fileList = [];
  late int index = widget.index;
  List<int> selectedMedias = [];
  bool selectionMode = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

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

    var secimIcon = secilimi == true ? Icons.check_circle : null;
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
                openGallery();
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
          fit: StackFit.expand,
          children: [
            media!,
            Positioned(
              left: 1,
              top: 1,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    height: 10,
                    width: 10,
                    child: IconButton(
                      iconSize: 16,
                      icon: Icon(secimIcon, color: Colors.white),
                      color: Colors.white,
                      onPressed: () {
                        selectMedia(Medias);
                      },
                    ),
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
    return getScaffold(selectedMedias);
  }

  openGallery() {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Stack(alignment: Alignment.bottomLeft, children: [
              PhotoViewGallery.builder(
                pageController: widget.pageController,
                itemCount: fileList.length,
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(
                        ioo.File(fileList[index].path.toString()),
                      ),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2);
                },
                onPageChanged: (index) => setState(() {
                  this.index = index;
                }),
                scrollPhysics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                enableRotation: true,
                backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor),
                loadingBuilder: (context, event) => Center(
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 8),
                  child: Text(
                    'Resim ${index + 1}/${fileList.length.toString()}',
                    style: TextStyle(),
                  ),
                ),
              )
            ])));
  }

  getScaffold(List<int> selecteds) {
    if (selectionMode == true) {
      return WillPopScope(
        onWillPop: () async {
          if (isDialOpen.value) {
            isDialOpen.value = false;
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
            floatingActionButton: SpeedDial(
              openCloseDial: isDialOpen,
              activeIcon: Icons.cancel,
              tooltip: 'Seçilenler',
              icon: Icons.more_vert,
              //animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Color(0xff017eba),
              activeBackgroundColor: Colors.red,
              activeForegroundColor: Colors.white,
              closeManually: true,
              children: [
                SpeedDialChild(
                  onTap: () {},
                  child: Icon(Icons.map),
                  label: 'Seçilenleri Haritalandır',
                  backgroundColor: Color(0xff26334d),
                  labelBackgroundColor: Color(0xff26334d),
                ),
                SpeedDialChild(
                  onTap: () {
                    // seçilen Medyaları obje olarak almak için boş bir dizi oluşturduk
                    List<Medias> secilenMedyalar = [];
                    // Listedeki tüm medyaların sadece seçilenleri yukarıdaki diziye eklemek için for ile döndük.
                    for (int i = 0; i < fileList.length; i++) {
                      Medias item = fileList[i];
                      if (selecteds.indexOf(item.id!) != -1) {
                        secilenMedyalar.add(item);
                      }
                    }
                    // artık Seçili medyaları Medias objesi olarak listeleyip almış olduk
                    Media_VM.getMedyaShareDialog(context, secilenMedyalar);
                    setState(() {
                      selectedMedias.clear();
                      selectionMode = false;
                    });
                  },
                  child: Icon(Icons.share),
                  label: 'Seçilenleri Paylaş',
                  backgroundColor: Color(0xff26334d),
                  labelBackgroundColor: Color(0xff26334d),
                ),
                SpeedDialChild(
                  onTap: () {
                    setState(() {
                      selectedMedias.clear();
                      selectionMode = false;
                    });
                  },
                  child: Icon(Icons.cancel),
                  label: 'Seçimi İptal Et',
                  backgroundColor: Color(0xff26334d),
                  labelBackgroundColor: Color(0xff26334d),
                ),
                SpeedDialChild(
                  onTap: () async {
                    Util.evetHayir(context, 'Toplu Medya Silme İşlemi',
                        '${selecteds.length} Adet medya öğesini silmek istediğinize emin misiniz?',
                        (cevap) async {
                      if (cevap == true) {
                        int silinenDosyaSayisi =
                            await AlbumDataBase.mediaMultiDelete(selecteds);

                        SBBildirim.bilgi(
                            '${silinenDosyaSayisi} Adet medya silinmiştir.');
                        setState(() {
                          deleteMediasFromList(selecteds);
                        });
                      }
                    });
                    setState(() {
                      selectionMode = false;

                      // getFileList(widget.id!);
                    });
                  },
                  child: Icon(Icons.delete),
                  label: 'Seçilenleri Sil',
                  backgroundColor: Color(0xff26334d),
                  labelBackgroundColor: Color(0xff26334d),
                ),
                SpeedDialChild(
                  child: Icon(Icons.check),
                  onTap: () {
                    List<int> listem = [];
                    for (int i = 0; i < fileList.length; i++) {
                      int allList = fileList[i].id!;
                      listem.add(allList);
                    }
                    setState(() {
                      selectedMedias = listem;
                    });
                  },
                  label: 'Hepsini Seç',
                  backgroundColor: Color(0xff26334d),
                  labelBackgroundColor: Color(0xff26334d),
                ),
              ],
            ),
            body: GridView.builder(
                itemCount: fileList.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: context.dynamicWidth(4),
                  maxCrossAxisExtent: context.dynamicHeight(8),
                ),
                itemBuilder: (BuildContext context, int index) {
                  return mediaCardBuilder(fileList[index]);
                })),
      );
    } else {
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
          ),
          itemBuilder: (BuildContext context, int index) {
            return mediaCardBuilder(fileList[index]);
          },
        ),
      );
    }
  }

  deleteMediasFromList(List<int> selecteds) {
    List<Medias> clearList = [];
    for (int i = 0; i < fileList.length; i++) {
      Medias list = fileList[i];
      int index = selecteds.indexOf(list.id!);
      if (index == -1) {
        clearList.add(list);
      }
    }
    setState(() {
      selectedMedias = [];
      selectionMode = false;
      fileList = clearList;
    });
  }
}
