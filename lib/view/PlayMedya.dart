import 'dart:io' as ioo;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Album.dart';
import '../providers/MedyaProvider.dart';
import 'Medya.dart';

class PlayMedya extends StatefulWidget {
  late int index;

  PlayMedya({
    required this.index,
  });

  @override
  State<PlayMedya> createState() => _PlayMedyaState();
}

class _PlayMedyaState extends State<PlayMedya> {
  late MediaProvider mediaProvider;
  MedyaState state = MedyaState();
  @override
  void initState() {
    mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Medias> myfileList = mediaProvider.fileList;
    return Scaffold(
        body: Center(
      child: Container(
          child: CarouselSlider.builder(
              itemCount: myfileList.length,
              options: CarouselOptions(
                initialPage: widget.index,
                aspectRatio: 1.0,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                autoPlay: true,
              ),
              itemBuilder: (BuildContext context, index, int pageViewIndex) {
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
                        child: state.openVideo(mymedia),
                      );
                    }
                  case 'audio':
                    {
                      return Container();
                    }
                  case 'txt':
                    {
                      return Container();
                    }
                  default:
                    {
                      return Container();
                    }
                }
              })),
    ));
  }
}
