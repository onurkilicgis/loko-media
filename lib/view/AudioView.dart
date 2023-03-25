import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../models/Album.dart';
import '../providers/SwitchProvider.dart';
import 'AudioRecorder.dart';

class AudioView extends StatefulWidget {
   Medias medias;
   late bool appbarstatus;
   late String type;

  AudioView({required this.medias, required this.appbarstatus,required this.type});

  @override
  State<AudioView> createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  final player = FlutterSoundPlayer();
  String? filePath;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration ilaveBilgi = Duration.zero;
  bool playGostersinmi = true;
  String isDark = 'dark';

  @override
  void initState() {
    openPlayer();
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: widget.appbarstatus == true
          ? AppBar(
              centerTitle: true,
              title: Text('a105'.tr),
            )
          : null,
      body: Consumer<SwitchModel>(builder: (context, switchModel, child) {
        return SafeArea(child: buildCenter(switchModel.isSwitchControl));
      }),
    );
  }

  Widget buildCenter(themeStatus) {
    dynamic settings = json.decode(widget.medias.settings.toString());
    duration = Duration(milliseconds: settings['duration']);
    ilaveBilgi = Duration(milliseconds: settings['duration']);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.topCenter, children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: themeStatus == 'dark'
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.black45,
                          child: Image.asset(
                            'assets/images/audio_dark.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.black45,
                          child: Image.asset(
                            'assets/images/audio_light.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
           widget.medias!=null ?
             widget.medias.name == null
                ? Text('')
                : Positioned(
                    top: 15,
                    child: Text(
                      widget.medias.name!,
                      style: TextStyle(fontSize: 18),
                    ),
                  ):Text('')
          ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Slider(
              activeColor: Theme.of(context).canvasColor,
              inactiveColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds.toDouble(),
              onChangeEnd: (value) async {
                int milisecond = (value).toInt();

                position = Duration(milliseconds: milisecond);
                await player.seekToPlayer(position);
                await resumePlay();
                setState(() {});

                //
              },
              onChanged: (double value) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AudioRecorderState.formatTime(position)),
                Text(AudioRecorderState.formatTime(duration - position))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).canvasColor,
              radius: 35,
              child: IconButton(
                icon: Icon(
                    playGostersinmi
                        ? Icons.play_arrow
                        : player.isPaused
                            ? Icons.play_arrow
                            : player.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                    color: Color(0xBEFFFFFF)),
                iconSize: 30,
                tooltip: 'a100'.tr,
                onPressed: () async {
                  if (player.isPaused) {
                    await resumePlay();
                  } else {
                    if (player.isPlaying) {
                      await pausePlay();
                    } else {
                     if(widget.type=='file'){
                       await startPlay(widget.medias.path!);
                     } else{
                       await startPlay(widget.medias.path!);
                     }
                      playGostersinmi = false;
                    }
                  }
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      )),
    );
  }

  openPlayer() async {
    await player.openPlayer();
    if (player.isOpen()) {
      player.setSubscriptionDuration(Duration(milliseconds: 100));
      player.onProgress!.listen((e) async {
        int fark = e.duration.inMilliseconds - e.position.inMilliseconds;
        duration = e.duration;
        position = e.position;
        if (fark <= 200) {
          duration = e.duration;
          position = ilaveBilgi;
          playGostersinmi = true;
        }

        setState(() {});
      });
    }
  }

  Future startPlay(String filePath) async {
    if(widget.type=='url'){
      var response = await http.get(Uri.parse(filePath));
      List<int> bytes = response.bodyBytes;
      Uint8List buffer = Uint8List.fromList(bytes);
      await player.startPlayer(
        fromDataBuffer: buffer
      );
    }else{
      await player.startPlayer(fromURI: filePath);
      }

  }

  Future stopPlay() async {
    await player.stopPlayer();
  }

  Future pausePlay() async {
    await player.pausePlayer();
  }

  Future resumePlay() async {
    await player.resumePlayer();
  }
}
