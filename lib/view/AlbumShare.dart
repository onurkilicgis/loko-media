import 'package:flutter/material.dart';

import '../models/Album.dart';

class AlbumShare extends StatefulWidget {
  String? type;
  dynamic info;
  List<Medias?> mediaList;

  AlbumShare({required this.type, required this.info, required this.mediaList});

  @override
  State<AlbumShare> createState() => _AlbumShareState();
}

class _AlbumShareState extends State<AlbumShare> {
  late TextEditingController _albumNameController;
  TextEditingController _albumIcerikController = TextEditingController();
  TextEditingController _kisiNameController = TextEditingController();
  int radioValueLocation = 0;
  int radioValueShare = 0;
  bool isVisible = false;
  int rangeMax = 60;
  int currentValue = 1;
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
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Albüm Adı Giriniz'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              value = _albumNameController.text;
            },
            controller: _albumNameController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.white,
            textCapitalization: TextCapitalization.words,
            maxLines: 2,
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
          padding: const EdgeInsets.all(8.0),
          child: Text('Albüm Açıklaması Giriniz'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _albumIcerikController,
            keyboardType: TextInputType.text,
            cursorColor: Colors.white,
            textCapitalization: TextCapitalization.words,
            maxLines: 5,
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
          padding: const EdgeInsets.all(8.0),
          child: Text('Konum Paylaşımı'),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                  tileColor: Color(0xff192132),
                  title: Text('Evet Paylaş'),
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
                  title: Text('Hayır Paylaşma'),
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
          padding: const EdgeInsets.all(8.0),
          child: Text('Paylaşım Süresi'),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                  tileColor: Color(0xff192132),
                  title: Text('Süresiz Paylaş'),
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
                  title: Text('Süreli Paylaş'),
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
                    icon: const Icon(Icons.arrow_downward),
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
        Text('Paylaşılan Kişiler'),
        TextField(
          onChanged: (value) {
            value = _kisiNameController.text;
          },
          controller: _kisiNameController,
          keyboardType: TextInputType.text,
          cursorColor: Colors.white,
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
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
      ]),
    );
  }
}
