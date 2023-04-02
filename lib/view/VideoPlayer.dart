import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as ioo;

import '../view_model/folder_model.dart';

class MyVideoPlayer extends StatefulWidget {

  String path;
  String type;
  dynamic item;

  MyVideoPlayer({Key? key, required this.path, required this.type, required this.item});

  @override
  State<MyVideoPlayer> createState() => _VideoPlayerState();
}


class _VideoPlayerState extends State<MyVideoPlayer> {

  bool loadStatus = false;
  late ioo.File file;


  loadFile()async{
    if(widget.type=='url'){
      var response = await http.get(Uri.parse(widget.path));
      List<int> bytes = response.bodyBytes;
      Uint8List buffer = Uint8List.fromList(bytes);
      String fakeFileName = widget.item['url'];
      String fakepath  = await FolderModel.getRootPath(fakeFileName);
      file  = new ioo.File(fakepath);
      file.writeAsBytesSync(buffer);
      loadStatus=true;
      setState(() {
        
      });
    }else{
      
    }

  }

  @override
  void initState() {
    // TODO: implement initState

    loadFile();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return loadStatus == false ? Container():Container(
      child: Chewie(
        controller: ChewieController(
            videoPlayerController: VideoPlayerController.file(
              file,videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            ),
            autoPlay: false,
            allowFullScreen: true,
            //fullScreenByDefault: true,

            autoInitialize: true,
            looping: false,
            aspectRatio: 0.7,

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
