import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();
  bool isrecorderReady = false;
  bool isVisiblePause = false;
  bool isVisibleStart = false;

  @override
  void initState() {
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final twoDigitMinutes =
                  twoDigits(duration.inMinutes.remainder(60));
              final twodigitSeconds =
                  twoDigits(duration.inSeconds.remainder(60));
              return CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.indigo,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.mic),
                          Text('${twoDigitMinutes}:${twodigitSeconds}'),
                          SizedBox(),
                          Text(recorder.isRecording ? 'kayıt' : 'Başlat')
                        ],
                      )));
            },
            stream: recorder.onProgress,
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              startStopRecord(),
              Visibility(visible: isVisiblePause, child: pauseResumeRecord())
            ],
          ),
        ],
      )),
    );
  }

  Widget startStopRecord() {
    final icon = recorder.isRecording ? Icons.stop : Icons.mic;
    final text = recorder.isRecording ? 'Stop' : 'Start';
    final backgroundColor = recorder.isRecording ? Colors.red : Colors.green;
    final foregroundColor = recorder.isRecording ? Colors.white : Colors.black;

    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor),
        onPressed: () async {
          if (recorder.isRecording) {
            await stopRecord();
            setState(() {});
          } else {
            await startRecord();
            setState(() {
              isVisiblePause = !isVisiblePause;
            });
          }
        },
        icon: Icon(icon),
        label: Text(text));
  }

  Widget pauseResumeRecord() {
    final icon = recorder.isRecording ? Icons.pause : Icons.play_arrow;
    final text = recorder.isRecording ? 'Durdur' : 'Devam et';
    final backgroundColor = recorder.isRecording ? Colors.yellow : Colors.white;
    final foregroundColor = recorder.isRecording ? Colors.white : Colors.black;

    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor),
        onPressed: () async {
          if (recorder.isRecording) {
            await pauseRecord();
            setState(() {});
          } else {
            await resumeRecord();
            setState(() {});
          }
        },
        icon: Icon(icon),
        label: Text(text));
  }

  // Widget play() {}

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'permission not granted';
    }

    await recorder.openRecorder();
    isrecorderReady = true;
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future startRecord() async {
    if (!isrecorderReady) return;
    //toFile ile kaydedilmekte olan dosyanın yolu
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stopRecord() async {
    if (!isrecorderReady) return;
    final filePath = await recorder.stopRecorder();
    final audioFile = File(filePath!);
    //audioplayerda file kullanılcak
  }

  Future pauseRecord() async {
    await recorder.pauseRecorder();
  }

  Future resumeRecord() async {
    await recorder.resumeRecorder();
  }

  /*Future startPlay() async {
    await player.startPlayer(
      //oynatmak istediğin dosya
      fromURI:
    );
  }*/

  Future stopPlay() async {
    await player.stopPlayer();
  }
}
