import 'package:flutter/material.dart';

class CurrentDate {
  static zeroCheck(int num) {
    if (num < 10) {
      return "0" + num.toString();
    } else {
      return num.toString();
    }
  }

  static getNow() {
    var now = new DateTime.now();
    String ay = zeroCheck(now.month);
    String gun = zeroCheck(now.day);
    String yil = now.year.toString();
    String saat = zeroCheck(now.hour);
    String dakika = zeroCheck(now.minute);
    String saniye = zeroCheck(now.second);
    return "${gun}/${ay}/${yil} ${saat}:${dakika}:${saniye}";
  }
}

class Album {
  int? id;
  String? uid;
  String? name;
  bool? isPublic;
  String? url;
  String? image;
  String? date;
  bool? status;
  int? itemCount;

  Album(
      {this.id,
      this.uid,
      this.name,
      this.isPublic,
      this.url,
      this.image,
      this.date,
      this.status,
      this.itemCount});

  insertData(String name, String uid) {
    this.name = name;

    this.date = CurrentDate.getNow();
    this.uid = uid;
    this.isPublic = false;
    this.url = '';
    this.image = '';
    this.status = true;
    this.itemCount = 0;
    return this;
  }

  Album.fromJson(json) {
    id = json['id'];
    uid = json['uid'];
    name = json['name'];
    isPublic = json['isPublic'] == 1 ? true : false;
    url = json['url'];
    image = json['image'];
    date = json['date'];
    status = json['status'] == 1 ? true : false;
    itemCount = json['itemCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['isPublic'] = this.isPublic == 1 ? true : false;
    data['url'] = this.url;
    data['image'] = this.image;
    data['date'] = this.date;
    data['status'] = this.status == 1 ? true : false;
    data['itemCount'] = this.itemCount;
    return data;
  }
}

class Medias {
  int? id;
  int? album_id;
  String? name;
  String? miniName;
  String? fileType;
  String? path;
  bool? isPublic;
  String? url;
  int? api_id;
  String? date;
  bool? status;
  double? latitude;
  double? longitude;
  double? altitude;

  Medias(
      {this.id,
      required this.album_id,
      required this.name,
      required this.miniName,
      required this.fileType,
      required this.path,
      this.isPublic,
      this.url,
      this.api_id,
      this.date,
      required this.latitude,
      required this.longitude,
      required this.altitude,
      this.status});

  Medias.fromJson(json) {
    id = json['id'];
    album_id = json['album_id'];
    name = json['name'];
    miniName = json['miniName'];
    fileType = json['fileType'];
    path = json['path'];
    isPublic = json['isPublic'] == 1 ? true : false;
    url = json['url'];
    api_id = json['api_id'];
    date = json['date'];
    status = json['status'] == 1 ? true : false;
    latitude = json['latitude'];
    longitude = json['longitude'];
    altitude = json['altitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['album_id'] = this.album_id;
    data['name'] = this.name;
    data['miniName'] = this.miniName;
    data['fileType'] = this.fileType;
    data['path'] = this.path;
    data['isPublic'] = this.isPublic;
    data['url'] = this.url;
    data['api_id'] = this.api_id;
    data['date'] = this.date;
    data['status'] = this.status;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['altitude'] = this.altitude;
    return data;
  }

  insertData() {
    this.name = name;
    this.isPublic = false;
    this.url = '';
    this.api_id = 0;
    this.date = CurrentDate.getNow();
    this.status = true;
  }
}

class Util {
  static evetHayir(context, baslik, soru, Function callback) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            title: Text(baslik),
            content: Text(soru,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                )),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        callback(true);
                      },
                      child: Text('Evet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xfffd7e7e),
                          ))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        callback(false);
                      },
                      child: Text('Hayır',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff80C783),
                          )))
                ],
              )
            ],
          );
        });
  }
}
