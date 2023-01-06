import 'dart:convert';
import 'dart:io' as ioo;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:loko_media/view/app.dart';
import 'package:loko_media/view_model/folder_model.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../database/AlbumDataBase.dart';
import '../models/Album.dart';
import '../providers/MedyaProvider.dart';
import '../services/GPS.dart';
import '../services/Loader.dart';
import '../services/MyLocal.dart';
import '../services/utils.dart';

class AudioRecorder extends StatefulWidget {
  late int aktifTabIndex;
  late AppState model;

  AudioRecorder({required this.aktifTabIndex, required this.model});

  @override
  State<AudioRecorder> createState() => AudioRecorderState();
}

class AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isrecorderReady = false;
  bool playGostersinmi = true;

  String mod = 'kayit-yok';
  String? filePath;
  late Uint8List sesDosyasi;
  String? fileName;
  File? audio;
  String isDark = 'dark';
  findTheme() async {
    isDark = await MyLocal.getStringData('theme');
  }

  late Duration currentDuration;
  TextEditingController audioNameController = TextEditingController();

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
          position = e.duration;
          playGostersinmi = true;
        }
        setState(() {});
      });
    }
  }

  late MediaProvider _mediaProvider;

  //static BuildContext? appContext;

  @override
  void initState() {
    //AudioRecorderState.appContext = context;
    findTheme();
    initRecorder();

    openPlayer();

    _mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    super.initState();
  }

  @override
  Future<void> dispose() async {
    recorder.closeRecorder();
    player.closePlayer();
    if (filePath != null) {
      await deleteRecord(filePath);
    }

    super.dispose();
  }

  Widget baslaButonu() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50),
            backgroundColor: Color(0xff5ba560),
            foregroundColor: Color(0xD8FFFFFF),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () async {
          await startRecord();
          setState(() {
            mod = 'kayit-basladi';
          });
        },
        icon: Icon(Icons.mic),
        label: Text('Başlat'));
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
            backgroundColor: Color(0xffa50909),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
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
    final backgroundColor = durum ? Color(0xffb4a30c) : Color(0xff5ba560);
    final foregroundColor = Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              minimumSize: Size(100, 50),
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
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
          label: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ustButonlar = [];

    switch (mod) {
      case 'kayit-yok':
        {
          ustButonlar.add(baslaButonu());
          break;
        }
      case 'kayit-basladi':
        {
          ustButonlar.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: bitirButonu(),
          ));

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
              duration =
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
                      backgroundColor: Color(0xff31376a),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Color(0xBEFFFFFF),
                          ),
                          Text(
                            '${twoDigitMinutes}:${twodigitSeconds}',
                            style: TextStyle(
                                fontSize: 40, color: Color(0xBEFFFFFF)),
                          ),
                          SizedBox(),
                          Text(
                            recorder.isRecording
                                ? 'Kayıt  Ediyor...'
                                : 'Başlata Basınız.',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xC3FFFFFF)),
                          ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Slider(
                    activeColor: Color(0xff31376a),
                    inactiveColor: Color(0xBEFFFFFF),
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
                      Text(formatTime(position)),
                      Text(formatTime(duration - position))
                    ],
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                    backgroundColor: Color(0xff31376a),
                    radius: 35,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Color(0xBEFFFFFF)),
                      tooltip: 'Kaydı Sil',
                      iconSize: 30,
                      onPressed: () async {
                        Util.evetHayir(context, 'Kayıt Silme İşlemi',
                            'Bu medya öğesini silmek istediğinize emin misiniz?',
                            (cevap) async {
                          if (cevap == true) {
                            await deleteRecord(filePath);
                            SBBildirim.bilgi("Bu Medya Öğesi Silinmiştir.");
                          }
                        });

                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Color(0xff31376a),
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
                        tooltip: 'Dinle',
                        onPressed: () async {
                          if (player.isPaused) {
                            await resumePlay();
                          } else {
                            if (player.isPlaying) {
                              await pausePlay();
                            } else {
                              await startPlay(filePath);
                              playGostersinmi = false;
                            }
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xff31376a),
                    radius: 35,
                    child: IconButton(
                      icon: Icon(Icons.save, color: Color(0xBEFFFFFF)),
                      tooltip: 'Kaydet',
                      iconSize: 30,
                      onPressed: () {
                        getAudioDialog();
                      },
                    ),
                  ),
                ])
              ],
            ),
          )
        ],
      )),
    );
  }

  Future audioInsertFile(
    String name,
    String filePath,
  ) async {
    try {
      if (filePath == null) return;
      if (filePath != null) {
        Loading.waiting('Ses Kayıt Yükleniyor');
      }

      dynamic positions = await GPS.getGPSPosition();
      if (positions['status'] == false) {
        SBBildirim.uyari(positions['message']);
        return;
      }
      await AlbumDataBase.createAlbumIfTableEmpty('İsimsiz Album');
      final imageTemporary = File(filePath);
      int aktifAlbumId = await MyLocal.getIntData('aktifalbum');
      int now = DateTime.now().millisecondsSinceEpoch;
      var parts = filePath.split('.');
      String extension = 'm4a';

      String filename = 'audio-' + now.toString() + '.' + extension;
      String miniFilename = 'audio-' + now.toString() + '-mini.' + extension;
      Uint8List bytes = imageTemporary.readAsBytesSync();
      dynamic? newPath = await FolderModel.createFile(
          'albums/album-${aktifAlbumId}',
          bytes,
          filename,
          miniFilename,
          'audio');
      Medias dbAudio = new Medias(
        album_id: aktifAlbumId,
        name: name,
        miniName: '',
        path: newPath['file'],
        latitude: positions['latitude'],
        longitude: positions['longitude'],
        altitude: positions['altitude'],
        fileType: 'audio',
      );
      dbAudio.insertData({'duration': duration.inMilliseconds});
      await AlbumDataBase.insertFile(dbAudio, '', (lastId) {
        dbAudio.id = lastId;
        widget.model.getAlbumList();
      });
      Loading.close();
      if (widget.aktifTabIndex == 2) {
        _mediaProvider.addMedia(dbAudio);
      }
    } on PlatformException catch (e) {
      SBBildirim.hata(e.toString());
    }
  }

  getAudioDialog() {
    Navigator.pop(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Ses Kayıt'),
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          actions: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: context.dynamicWidth(18),
                      right: context.dynamicWidth(18)),
                  child: TextField(
                    controller: audioNameController,
                    keyboardType: TextInputType.text,
                    // textAlign: TextAlign.center,
                    cursorColor: Colors.white,

                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Ses Kayıt Adı Giriniz',
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    child: Text(
                      'İptal',
                      style: TextStyle(color: Color(0xffe55656), fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () async {
                          if (audioNameController.text != '') {
                            Navigator.pop(context);
                            await audioInsertFile(
                                audioNameController.text, filePath!);
                            //MedyaState.audioCard();
                          }
                        },
                        child: Text('Tamam',
                            style: TextStyle(
                                color: Color(0xff80C783), fontSize: 17))),
                  )
                ])
              ],
            )
          ],
        );
      },
    );
  }

  static String formatTime(Duration duration) {
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
    sesDosyasi = ioo.File(filePath!).readAsBytesSync();

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

  Future deleteRecord(String? filePath) async {
    await recorder.deleteRecord(fileName: filePath!);
    filePath = null;

    setState(() {});
  }

  Future startPlay(filePath) async {
    await player.startPlayer(
        //oynatmak istediğin dosya
        // fromDataBuffer: dosya,
        fromURI: filePath);
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

  openLongAudio(context, Medias medias, filePath) {
    dynamic settings = json.decode(medias.settings.toString());
    duration = Duration(milliseconds: settings['duration']);
    position = Duration(milliseconds: 0);

    openPlayer();

    return Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => Container(
              color: Color(0xff7a7c99),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(alignment: Alignment.topCenter, children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: isDark == 'dark'
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
                    medias.name == null
                        ? Text('')
                        : Positioned(
                            top: 15,
                            child: Text(
                              medias.name!,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Slider(
                      activeColor: Color(0xff31376a),
                      inactiveColor: Color(0xBEFFFFFF),
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
                        Text(formatTime(position)),
                        Text(formatTime(duration - position))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Color(0xff31376a),
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
                        tooltip: 'Dinle',
                        onPressed: () async {
                          if (player.isPaused) {
                            await resumePlay();
                          } else {
                            if (player.isPlaying) {
                              await pausePlay();
                            } else {
                              await startPlay(filePath);
                              playGostersinmi = false;
                            }
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
