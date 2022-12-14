import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:loko_media/view_model/folder_model.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();
  final audioPlayer = AudioPlayer();
  dynamic? source;
  // final cache = AudioCache();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isrecorderReady = false;

  String mod = 'kayit-yok';
  String? filePath;
  String? fileName;
  //late Duration maxDuration;
  // late Duration elapsedDuration;
  late Duration currentDuration;
  //kayit-yok - sadece başlatı göster
  //kayit-basladi - bitir ve durduru göster
  //kayit-durduruldu - bitir ve devam eti göster
  //kayit-bitti - hiç birini gösterme - Tekrar kayıt diye bir butpn olsun.

  @override
  void initState() {
    initRecorder();
    setAudio();

    /*  audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        //  isPlaying = state == PlayerState.PLAYING;
      });
    });*/
    audioPlayer.onDurationChanged.listen((newDuraiton) {
      setState(() {
        duration = newDuraiton;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  Widget baslaButonu() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(100, 50),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          await startRecord();
          setState(() {
            mod = 'kayit-basladi';
          });
        },
        icon: Icon(Icons.mic),
        label: Text('Başla'));
  }

  Widget iptalEtTekrarBaslaButonu() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(100, 50),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          await stopRecord();
          setState(() {
            mod = 'kayit-basladi';
          });
        },
        icon: Icon(Icons.refresh),
        label: Text('İptal Et ve Tekrar Kayıda Başla'));
  }

  Widget bitirButonu() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(100, 50),
          backgroundColor: Colors.red,
          foregroundColor: Colors.black,
        ),
        onPressed: () async {
          await stopRecord();
          setState(() {
            mod = 'kayit-bitti';
          });
        },
        icon: Icon(Icons.stop),
        label: Text('Bitir'));
  }

  Widget durdurCalistirIconu(bool durum) {
    final icon = durum ? Icons.pause : Icons.play_arrow;
    final text = durum ? 'Durdur' : 'Devam et';
    final backgroundColor = durum ? Colors.yellow : Colors.white;
    final foregroundColor = Colors.black;

    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor),
        onPressed: () async {
          if (recorder.isRecording) {
            await pauseRecord();
          } else {
            await resumeRecord();
          }
          setState(() {
            mod = recorder.isRecording == false
                ? 'kayit-durduruldu'
                : 'kayit-basladi';
          });
        },
        icon: Icon(icon),
        label: Text(text));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ustButonlar = [];
    Widget wave = Container();
    switch (mod) {
      case 'kayit-yok':
        {
          ustButonlar.add(baslaButonu());
          break;
        }
      case 'kayit-basladi':
        {
          ustButonlar.add(bitirButonu());
          ustButonlar.add(durdurCalistirIconu(true));
          break;
        }
      case 'kayit-durduruldu':
        {
          ustButonlar.add(bitirButonu());
          ustButonlar.add(durdurCalistirIconu(false));
          break;
        }
      case 'kayit-bitti':
        {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ses Kayıt Paneli'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              currentDuration = duration;
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final twoDigitMinutes =
                  twoDigits(duration.inMinutes.remainder(60));
              final twodigitSeconds =
                  twoDigits(duration.inSeconds.remainder(60));

              return CircleAvatar(
                  radius: 93,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.indigo,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.mic),
                          Text(
                            '${twoDigitMinutes}:${twodigitSeconds}',
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(),
                          Text(recorder.isRecording ? 'Kayıt' : 'Başlat')
                        ],
                      )));
            },
            stream: recorder.onProgress,
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ustButonlar,
          ),
          Visibility(
            visible: mod == 'kayit-bitti' ? true : false,
            child: Column(
              children: [
                Slider(
                  activeColor: Colors.teal,
                  inactiveColor: Colors.deepPurple,
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position)),
                      Text(formatTime(duration - position))
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  child: IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        await audioPlayer.play(source);
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 50),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.save),
                        label: Text('Kaydet')),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(100, 50),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          icon: Icon(Icons.headset),
                          label: Text('Dinle')),
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 50),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await deleteRecord();
                          setState(() {});
                        },
                        icon: Icon(Icons.delete),
                        label: Text('İptal Et')),
                  ],
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    source = audioPlayer.setSourceUrl(
      filePath!,
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

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
    filePath = await FolderModel.generateAudioPath();
    int now = DateTime.now().millisecondsSinceEpoch;
    fileName = 'audio-' + now.toString();
    recorder.startRecorder(toFile: fileName);
  }

  Future stopRecord() async {
    if (!isrecorderReady) return;
    filePath = await recorder.stopRecorder();
    // final audioFile = File(filePath!);

    setState(() {});
    //print(audioFile);
    //audioplayerda file kullanılcak
  }

  Future pauseRecord() async {
    await recorder.pauseRecorder();
  }

  Future resumeRecord() async {
    await recorder.resumeRecorder();
  }

  Future deleteRecord() async {
    await recorder.deleteRecord(fileName: filePath!);
  }

  Future startPlay(whenfinished) async {
    await player.startPlayer(
        //oynatmak istediğin dosya
        fromURI: filePath,
        codec: Codec.mp3,
        whenFinished: whenfinished);
  }

  Future stopPlay() async {
    await player.stopPlayer();
  }
}
