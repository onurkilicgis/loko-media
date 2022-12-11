import 'dart:io' as ioo;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/Album.dart';
import '../providers/MedyaProvider.dart';

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
                        child: openVideo(mymedia),
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

  openVideo(Medias medias) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Chewie(
        controller: ChewieController(
            videoPlayerController:
                VideoPlayerController.file(ioo.File(medias.path.toString())),
            autoPlay: false,
            looping: false,
            aspectRatio: 1,
            errorBuilder: (context, errorMessage) {
              return Center(
                  child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ));
            },
            // allowFullScreen: true,
            additionalOptions: (context) {
              return <OptionItem>[
                //OptionItem(onTap: onTap, iconData: iconData, title: title)
              ];
            }),
      ),
    );
  }
}
