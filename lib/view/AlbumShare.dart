import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loko_media/database/AlbumDataBase.dart';
import 'package:loko_media/services/utils.dart';

import '../models/Album.dart';
import '../services/API2.dart';
import '../services/FileDrive.dart';
import '../services/MyLocal.dart';

class AlbumShare extends StatefulWidget {
  String? type;
  dynamic info;
  List<Medias> mediaList;

  AlbumShare({required this.type, required this.info, required this.mediaList});

  @override
  State<AlbumShare> createState() => _AlbumShareState();
}

class _AlbumShareState extends State<AlbumShare> {
  late TextEditingController _albumNameController;
  TextEditingController _albumIcerikController = TextEditingController();
  TextEditingController _kisiNameController = TextEditingController();
  int? radioValueLocation;
  int? radioValueShare;
  final ScrollController _controller = ScrollController();
  late int selectedKapak;
  List<dynamic> uploads = [];
  bool isLoading = false;
  double progress = 0.0;
  bool isVisible = false;
  List<int> selectedIndexes = [];
  int rangeMax = 60;
  int currentValue = 1;
  List<dynamic> selectedUsers = [];
  List<String> selectedUsersId = [];
  late List<dynamic> data;
  bool status = false;
  late Timer _timer;
  List<dynamic> selections = [
    {'name': 'Dakika', 'max': 60},
    {'name': 'Saat', 'max': 24},
    {'name': 'Gün', 'max': 31},
    {'name': 'Hafta', 'max': 52},
    {'name': 'Ay', 'max': 12},
    {'name': 'Yıl', 'max': 10},
  ];

  List<String> list = ['Dakika', 'Saat', 'Gün', 'Hafta', 'Ay', 'Yıl'];

  String dropdownValue = 'Dakika';

  populateUploads() {
    for (int i = 0; i < widget.mediaList.length; i++) {
      dynamic data = {
        'media': widget.mediaList[i],
        'progressValue': 0.0,
        'checked': true,
        'isUploaded': false,
        'uploadURL': ''
      };
      uploads.add(data);
    }
    setState(() {});
  }

  String isDark = 'dark';
  findTheme() async {
    isDark = await MyLocal.getStringData('theme');
  }

  getCardHeight(int itemCount, double max) {
    if (itemCount > 3) {
      itemCount = 3;
    }
    double maxHeight = itemCount * 65;
    if (maxHeight > max) {
      return max;
    } else {
      return maxHeight;
    }
  }

  getCardHeight2(List<dynamic> datalar, double max) {
    List<dynamic> kalan = [];
    for (int i = 0; i < datalar.length; i++) {
      if (selectedUsersId.indexOf(datalar[i]['id']) == -1) {
        kalan.add(datalar[i]);
      }
    }
    return getCardHeight(kalan.length, max);
  }

  @override
  void initState() {
    // TODO: implement initState
    _albumNameController = TextEditingController(text: widget.info['name']);
    selectedKapak = widget.mediaList[0].id!;
    radioValueLocation = 1;
    radioValueShare = 1;
    populateUploads();
    findTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: widget.type == 'album'
              ? Text('Albüm Paylaşma Paneli')
              : Text('Medya Paylaşma Paneli')),
      body: SafeArea(
        child: ListView(controller: _controller, children: [
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
              child: widget.type == 'album'
                  ? Text('Albüm Adı Giriniz', style: TextStyle(fontSize: 16))
                  : widget.type == 'medya'
                      ? Text('Medya Adı Giriniz',
                          style: TextStyle(fontSize: 16))
                      : Text('Başlık Giriniz')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                value = _albumNameController.text;
              },
              controller: _albumNameController,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.text,
              cursorColor: Colors.white,
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xff1e2c49),
                contentPadding: EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: Color(0xff017eba),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff017eba),
                  ),
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
              child: widget.type == 'album'
                  ? Text('Albüm Açıklaması Giriniz',
                      style: TextStyle(fontSize: 16))
                  : widget.type == 'medya'
                      ? Text('Medya Açıklaması Giriniz',
                          style: TextStyle(fontSize: 16))
                      : Text('Açıklama Giriniz')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _albumIcerikController,
              keyboardType: TextInputType.text,
              cursorColor: Colors.white,
              textCapitalization: TextCapitalization.words,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xff1e2c49),
                contentPadding: EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: Color(0xff017eba),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff017eba),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
            child: Text('Konum Paylaşımı', style: TextStyle(fontSize: 16)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: RadioListTile(
                    tileColor: Color(0xff192132),
                    title: Text('Evet Paylaş', style: TextStyle(fontSize: 13)),
                    activeColor: Color(0xff0e91ce),
                    value: 1,
                    groupValue: radioValueLocation,
                    onChanged: (int? veri) {
                      setState(() {
                        radioValueLocation = veri!;
                      });
                    }),
              ),
              Expanded(
                child: RadioListTile(
                    tileColor: Color(0xff192132),
                    title:
                        Text('Hayır Paylaşma', style: TextStyle(fontSize: 13)),
                    activeColor: Color(0xff0e91ce),
                    value: 2,
                    groupValue: radioValueLocation,
                    onChanged: (int? veri) {
                      setState(() {
                        radioValueLocation = veri!;
                      });
                    }),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
            child: Text('Paylaşım Süresi', style: TextStyle(fontSize: 16)),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                    tileColor: Color(0xff192132),
                    title: Text('Süresiz', style: TextStyle(fontSize: 13)),
                    activeColor: Color(0xff0e91ce),
                    value: 1,
                    groupValue: radioValueShare,
                    onChanged: (int? veri) {
                      setState(() {
                        radioValueShare = veri!;
                        isVisible = false;
                      });
                    }),
              ),
              Expanded(
                child: RadioListTile(
                    tileColor: Color(0xff192132),
                    title: Text('Süreli', style: TextStyle(fontSize: 13)),
                    activeColor: Color(0xff0e91ce),
                    value: 2,
                    groupValue: radioValueShare,
                    onChanged: (int? veri) {
                      setState(() {
                        radioValueShare = veri!;
                        isVisible = true;
                      });
                    }),
              )
            ],
          ),
          Visibility(
            visible: isVisible,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        '${currentValue.toInt()}' + ' ' + '${dropdownValue}',
                      ),
                    ),
                    Container(
                      width: 250,
                      child: Slider(
                        activeColor: Color(0xff0e91ce),
                        inactiveColor: Color(0xBEFFFFFF),
                        min: 1,
                        max: rangeMax.toDouble(),
                        value: currentValue.toDouble(),
                        onChanged: (value) async {
                          setState(() {
                            currentValue = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xff26334d),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration.collapsed(hintText: ''),
                      value: dropdownValue,
                      dropdownColor: Color(0xffc2c9d6),
                      iconEnabledColor: Color(0xff0e91ce),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(
                        color: Color(0xff0e91ce),
                      ),
                      onChanged: (String? value) {
                        for (int i = 0; i < selections.length; i++) {
                          if (value == selections[i]['name']) {
                            if (currentValue > selections[i]['max']) {
                              currentValue = selections[i]['max'];
                            }
                            setState(() {
                              rangeMax = selections[i]['max'];
                              dropdownValue = value!;
                            });
                            break;
                          }
                        }
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
          widget.info['kimlere'] == 'kisi'
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 5, left: 8),
                    child: Text(
                        'Paylaşılan Kişiler : ${selectedUsersId.length} Kişi',
                        style: TextStyle(fontSize: 16)),
                  ),
                  selectedUsersId.length > 0
                      ? Container(
                          height: getCardHeight(selectedUsersId.length, 300),
                          margin: EdgeInsets.only(bottom: 0),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedUsersId.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 8, right: 8, bottom: 0),
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            selectedUsers[index]['img'],
                                            scale: 1),
                                      ),
                                      title: Text(
                                          '${selectedUsers[index]['name']}'),
                                      trailing: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedUsersId.removeAt(index);
                                              selectedUsers.removeAt(index);
                                            });
                                          },
                                          child: Text(
                                            'Çıkart',
                                            style: TextStyle(
                                                color: Color(0xffffda15)),
                                          )),
                                    ),
                                  ),
                                );
                              }),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (name) async {
                        name = _kisiNameController.text;
                        if (name != "") {
                          dynamic userName = await API
                              .postRequest('api/lokomedia/searchFriends', {
                            'search': name,
                          });
                          if (userName['status'] == true) {
                            data = await userName['data'];
                            if (data.length > 0) {
                              _controller
                                  .jumpTo(_controller.position.maxScrollExtent);
                            }
                            setState(() {
                              status = true;
                            });
                          }
                        } else {
                          setState(() {
                            data = [];
                          });
                        }
                      },
                      controller: _kisiNameController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.white,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xff1e2c49),
                        contentPadding: EdgeInsets.all(8),
                        hintText: 'Kişi Ara... ',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: BorderSide(
                            color: Color(0xff017eba),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xff017eba),
                          ),
                        ),
                      ),
                    ),
                  ),
                  status == true
                      ? Container(
                          height: getCardHeight2(data, 300),
                          margin: EdgeInsets.only(bottom: 30),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (selectedUsersId
                                        .indexOf(data[index]['id']) ==
                                    -1) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 8, right: 8, bottom: 0),
                                    child: Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              data[index]['img'],
                                              scale: 1),
                                        ),
                                        title: Text('${data[index]['name']}'),
                                        //subtitle: Text('${data[index]['mail']}'),
                                        trailing: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                if (selectedUsersId.indexOf(
                                                        data[index]['id']) ==
                                                    -1) {
                                                  selectedUsers
                                                      .add(data[index]);
                                                  selectedUsersId
                                                      .add(data[index]['id']);
                                                }
                                              });
                                            },
                                            child: Text(
                                              'Ekle',
                                              style: TextStyle(
                                                  color: Color(0xff0e91ce)),
                                            )),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    child: null,
                                  );
                                }
                              }),
                        )
                      : Container(),
                ])
              : Container(),
          widget.type == 'album'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 0, bottom: 0, left: 8),
                      child: Text('Paylaşılacak Öğeler',
                          style: TextStyle(fontSize: 16)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              for (var i = 0; i < uploads.length; i++) {
                                dynamic check = uploads[i];

                                check['checked'] = false;
                              }
                              setState(() {});
                            },
                            child: Text('Tümünü İptal Et',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.color))),
                        TextButton(
                            onPressed: () {
                              for (var i = 0; i < uploads.length; i++) {
                                dynamic check = uploads[i];

                                check['checked'] = true;
                              }
                              setState(() {});
                            },
                            child: Text('Tümünü Seç',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.color))),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.mediaList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return mediasList(index);
                          }),
                    ),
                  ],
                )
              : Container(),
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, right: 10, left: 10),
            child: SizedBox(
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      paylas();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).listTileTheme.tileColor,
                        foregroundColor:
                            Theme.of(context).textTheme.headline5?.color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text(
                      'Paylaş',
                      style: TextStyle(fontSize: 18),
                    ))),
          )
        ]),
      ),
    );
  }

  medyaContainer(int index) {
    Medias medya = uploads[index]['media'];
    double mediaProggresValue = uploads[index]['progressValue'];
    switch (medya.fileType) {
      case 'image':
        {
          String? path = medya.path;
          String newPath = path!.replaceAll(medya.name!, medya.miniName!);
          return clipRRect(
              mediaProggresValue,
              Image.file(
                File(newPath),
                fit: BoxFit.cover,
              ));
        }
      case 'video':
        {
          String? path = medya.path;
          String newPath = path!.replaceAll(medya.name!, medya.miniName!);
          return Stack(alignment: Alignment.center, children: [
            clipRRect(
                mediaProggresValue,
                Image.file(
                  File(newPath),
                  fit: BoxFit.cover,
                )),
            Icon(Icons.play_circle_fill, color: Colors.white)
          ]);
        }
      case 'audio':
        {
          if (isDark == 'dark') {
            return Stack(
                // fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  clipRRect(
                    mediaProggresValue,
                    Image.asset(
                      'assets/images/audio_dark.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Icon(Icons.play_circle_fill, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(medya.name!,
                        style: TextStyle(fontSize: 7),
                        textAlign: TextAlign.center),
                  ),
                ]);
          } else {
            return Stack(alignment: Alignment.center, children: [
              clipRRect(
                mediaProggresValue,
                Image.asset(
                  'assets/images/audio_light.png',
                  fit: BoxFit.cover,
                ),
              ),
              Icon(Icons.play_circle_fill, color: Colors.white),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(medya.name!,
                    style: TextStyle(fontSize: 7), textAlign: TextAlign.center),
              ),
            ]);
          }
        }

      case 'txt':
        {
          if (isDark == 'dark') {
            return Stack(
                // fit: StackFit.expand,
                alignment: Alignment.topCenter,
                children: [
                  clipRRect(
                    mediaProggresValue,
                    Image.asset(
                      'assets/images/txt_dark.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(medya.name!,
                        style: TextStyle(fontSize: 7),
                        textAlign: TextAlign.center),
                  ),
                ]);
          } else {
            return Stack(alignment: Alignment.center, children: [
              clipRRect(
                mediaProggresValue,
                Image.asset(
                  'assets/images/txt_light.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(medya.name!,
                    style: TextStyle(fontSize: 7), textAlign: TextAlign.center),
              ),
            ]);
          }
        }
    }
  }

  Padding clipRRect(double mediaProggresValue, Image image) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        width: 50,
        height: 50,
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)), child: image),
      ),
    );
  }

  Padding mediasList(int index) {
    //xxx

    Medias medya = uploads[index]['media'];
    double mediaProggresValue = uploads[index]['progressValue'];
    bool medyaCheck = uploads[index]['checked'];
    int medyaid = int.parse(medya.id.toString());
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 2),
      child: Card(
        color: mediaProggresValue == 1.0
            ? Color(0xff5e995e)
            : Theme.of(context).listTileTheme.tileColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 4),
              child: Container(
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            medyaContainer(index),
                            Radio(
                              value: medyaid,
                              groupValue: selectedKapak,
                              activeColor: Color(0xff0e91ce),
                              onChanged: (int? value) {
                                setState(() {
                                  selectedKapak = value!;
                                });
                              },
                            ),
                            selectedKapak == medyaid
                                ? Text('Albüm Kapağı')
                                : Container()
                          ],
                        ),
                      ),
                      Container(
                        //color: Colors.lightBlue,
                        width: 40,
                        child: Checkbox(
                          value: medyaCheck,
                          activeColor: Color(0xff0e91ce),
                          onChanged: (bool? value) {
                            itemCheckBox(index, value!);
                          },
                        ),
                      ),
                    ]),
              ),
            ),
            LinearProgressIndicator(
                color: Color(0xff2b792f),
                backgroundColor: Color(0xff405d79),
                value: mediaProggresValue)
          ],
        ),
      ),
    );
  }

  void itemCheckBox(int index, bool checkStatus) {
    setState(() {
      uploads[index]['checked'] = checkStatus;
    });
  }

  paylas() async {
    List<dynamic> fileList = [];
    Bulut2 cloud = Bulut2();
    await cloud.ready();
    int yuklenmesiGerekenSayi = 0;
    int yuklenenGerekenSayi = 0;
    for (var i = 0; i < uploads.length; i++) {
      dynamic upload = uploads[i];
      if (upload['checked'] == true) {
        yuklenmesiGerekenSayi++;
        Medias media = upload['media'];
        if (media.url == "") {
          String? path = media.path;
          _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
            double total = upload['progressValue'] + 0.1;
            if (total < 1) {
              upload['progressValue'] = total;
              setState(() {
                uploads[i] = upload;
              });
            } else {
              _timer.cancel();
            }
          });
          dynamic uploadResponse = await API
              .fileUpload(media.path.toString(), {'type': media.fileType});
          if (uploadResponse['status'] == true) {
            yuklenenGerekenSayi++;
            String publicID = uploadResponse['data'].toString();
            media.isPublic = widget.info['kimlere'] == 'kisi'
                ? false
                : widget.info['kimlere'] == 'herkes'
                    ? true
                    : false;
            media.url = publicID;
            await AlbumDataBase.updateMediaPublicURL(media);
            fileList.add(media.getDynamic());
            if (publicID != false) {
              _timer.cancel();
              upload['media'] = media;
              upload['progressValue'] = 1.0;
              upload['isUploaded'] = true;
              upload['uploadURL'] = publicID;
              setState(() {
                uploads[i] = upload;
              });
            }
          } else {}
        } else {
          yuklenenGerekenSayi++;
          fileList.add(media.getDynamic());
          upload['progressValue'] = 1.0;
          upload['isUploaded'] = true;
          upload['uploadURL'] = media.url;
          setState(() {
            uploads[i] = upload;
          });
        }
      }
    }
    //-------------------
    if (yuklenenGerekenSayi == yuklenmesiGerekenSayi) {
      dynamic apiData = {
        'type': widget.type,
        'info': widget.info,
        'kapak': selectedKapak,
        'name': _albumNameController.text,
        'icerik': _albumIcerikController.text,
        'konum': radioValueLocation == 1 ? true : false,
        'suresiz': radioValueShare == 1 ? true : false,
        'sureType': dropdownValue,
        'sure': currentValue,
        'kisiler': selectedUsersId,
        'medias': fileList
      };
      String apiDataString = json.encode(apiData);
      print(apiDataString);
      dynamic islem = await API.postRequest('api/lokomedia/addShare', {
        'data': apiDataString,
      });
      if (islem['status'] == true) {
        SBBildirim.onay('Başarılı bir şekilde paylaşıldı');
        Navigator.pop(context);
      } else {
        SBBildirim.hata('Maalesef paylaşma işlemi başarısız oldu');
      }
    } else {
      SBBildirim.uyari('Yüklenmesi gereken öğeler yüklenemedi');
    }
  }
}
