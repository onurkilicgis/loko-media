import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/Album.dart';
import '../services/API2.dart';

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
  int? radioValueList;

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

  @override
  void initState() {
    // TODO: implement initState
    _albumNameController = TextEditingController(text: widget.info['name']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albüm Paylaşma Paneli'),
      ),
      body: ListView(controller: _controller, children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
          child: Text('Albüm Adı Giriniz', style: TextStyle(fontSize: 16)),
        ),
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
          child:
              Text('Albüm Açıklaması Giriniz', style: TextStyle(fontSize: 16)),
        ),
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
                  title: Text('Hayır Paylaşma', style: TextStyle(fontSize: 13)),
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
                  title: Text('Süresiz Paylaş', style: TextStyle(fontSize: 13)),
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
                  title: Text('Süreli Paylaş', style: TextStyle(fontSize: 13)),
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
                    width: 300,
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
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 5, left: 8),
          child: Text('Paylaşılan Kişiler : ${selectedUsersId.length} Kişi',
              style: TextStyle(fontSize: 16)),
        ),
        selectedUsersId.length > 0
            ? Container(
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
                            title: Text('${selectedUsers[index]['name']}'),
                            trailing: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedUsersId.removeAt(index);
                                    selectedUsers.removeAt(index);
                                  });
                                },
                                child: Text(
                                  'Çıkart',
                                  style: TextStyle(color: Color(0xffffda15)),
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
              dynamic userName =
                  await API.postRequest('api/lokomedia/searchFriends', {
                'search': name,
              });
              if (userName['status'] == true) {
                data = await userName['data'];
                if (data.length > 0) {
                  _controller.jumpTo(_controller.position.maxScrollExtent);
                }
                setState(() {
                  status = true;
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
                margin: EdgeInsets.only(bottom: 30),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (selectedUsersId.indexOf(data[index]['id']) == -1) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 0, left: 8, right: 8, bottom: 0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data[index]['img'], scale: 1),
                              ),
                              title: Text('${data[index]['name']}'),
                              trailing: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selectedUsersId
                                              .indexOf(data[index]['id']) ==
                                          -1) {
                                        selectedUsers.add(data[index]);
                                        selectedUsersId.add(data[index]['id']);
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Ekle',
                                    style: TextStyle(color: Color(0xff0e91ce)),
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
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 0, left: 8),
          child: Text('Paylaşılacak Öğeler', style: TextStyle(fontSize: 16)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {},
                child: Text('Tümünü İptal Et',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline5?.color))),
            TextButton(
                onPressed: () {},
                child: Text('Tümünü Seç',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline5?.color))),
          ],
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: widget.mediaList.length,
            itemBuilder: (BuildContext context, int index) {
              return mediasList(index);
            })
      ]),
    );
  }

  Padding mediasList(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            Container(
              child: Row(children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 50,
                        width: 50,
                        child: Image.file(
                          File(widget.mediaList[index].path!),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
                Expanded(
                  flex: 5,
                  child: RadioListTile(
                      tileColor: Theme.of(context).listTileTheme.tileColor,
                      title: Text('Albüm Kapağı'),
                      activeColor: Theme.of(context)
                          .bottomNavigationBarTheme
                          .selectedItemColor,
                      value: index,
                      groupValue: radioValueList,
                      onChanged: (int? veri) {
                        setState(() {
                          radioValueList = veri!;
                        });
                      }),
                ),
                Expanded(
                  flex: 3,
                  child: CheckboxListTile(
                      title: Text('Seç'),
                      value: selectedIndexes.contains(index),
                      checkColor: Color(0xff80C783),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).listTileTheme.tileColor,
                      onChanged: (isChecked) => _itemChange(index, isChecked!)),
                ),
              ]),
            ),
            isLoading == true
                ? LinearProgressIndicator(
                    backgroundColor:
                        Theme.of(context).textTheme.headline5?.color,
                    value: progress)
                : Container()
          ],
        ),
      ),
    );
  }

  void timeProgress() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        progress = progress + 0.1;
      });
    });
  }

  void _itemChange(int index, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedIndexes.add(index);
        isLoading = true;
        timeProgress();
      } else {
        selectedIndexes.remove(index);
        isLoading = false;
      }
    });
  }
}
