import 'dart:convert';
import 'dart:io' as ioo;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/view/Medya.dart';
import 'package:loko_media/view/TxtView.dart';
import 'package:provider/provider.dart';

import '../models/Album.dart';
import '../providers/MedyaProvider.dart';
import 'AudioView.dart';
import 'PdfView.dart';

class PlayMedya extends StatefulWidget {
  late int index;
  late MedyaState model;

  PlayMedya({required this.index, required this.model});

  @override
  State<PlayMedya> createState() => _PlayMedyaState();
}

class _PlayMedyaState extends State<PlayMedya> {
  late MediaProvider mediaProvider;

  @override
  void initState() {
    mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Medias> myfileList = mediaProvider.fileList;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('a138'.tr),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            child: Center(
              child: Container(
                  padding: EdgeInsets.all(0),
                  child: CarouselSlider.builder(
                      itemCount: myfileList.length,
                      options: CarouselOptions(
                        pageSnapping: true,
                        initialPage: widget.index,
                        aspectRatio: 0.9,
                        //viewportFraction: 0.8,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        autoPlay: false,
                      ),
                      itemBuilder:
                          (BuildContext context, index, int pageViewIndex) {
                        Medias mymedia = myfileList[index];
                        switch (mymedia.fileType) {
                          case 'image':
                            {
                              return Container(
                                  child: Image.file(ioo.File(mymedia.path!)));
                            }
                          case 'video':
                            {
                              return Container(
                                  child:
                                      widget.model.openVideo(mymedia, false));
                            }
                          case 'audio':
                            {
                              // AudioRecorderState recorder = AudioRecorderState();
                              return Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: AudioView(
                                    medias: mymedia, appbarstatus: false, type: 'file',),
                              );
                            }
                          case 'txt':
                            {
                              dynamic tip = json.decode(mymedia.settings!);
                              if (tip['type'] == 'txt') {
                                return Container(
                                  child: TxtView(
                                      medias: mymedia, appbarstatus: false),
                                );
                              } else {
                                return Container(
                                  child: PdfView(
                                      medias: mymedia, appbarstatus: false),
                                );
                              }
                            }
                          default:
                            {
                              return Container();
                            }
                        }
                      })),
            ),
          ),
        ));
  }
}
