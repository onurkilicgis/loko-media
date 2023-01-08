import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/API2.dart';

class Paylasimlar extends StatefulWidget {
  int? id;

  Paylasimlar({this.id});

  @override
  State<Paylasimlar> createState() => _PaylasimlarState();
}

class _PaylasimlarState extends State<Paylasimlar> {
  List<dynamic> item = [];
  late dynamic user;
  late dynamic kapak;
  late String medyaName;
  String? icerik;
  late String medyaType;
  late List<dynamic> medias;
  late String yorum;
  late int begeni;
  getSharesMedya() async {
    //https://drive.google.com/uc?id=
    dynamic medya =
        await API.postRequest("api/lokomedia/getShares", {'offset': "0"});
    if (medya['status'] == true) {
      item = medya['data'];
      for (int i = 0; i < item.length; i++) {
        user = item[i]['user'];
        kapak = item[i]['kapak'];
        medyaName = item[i]['name'];
        icerik = item[i]['content'];
        medyaType = item[i]['type'];
        medias = item[i]['medias'];
        //yorum = item[i]['comment'];
        begeni = item[i]['like'];
      }
    }
  }

  @override
  void initState() {
    getSharesMedya();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        ListView.builder(
            itemCount: item.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                    backgroundImage: NetworkImage(user['img'])),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['name']),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Albüm Adı:${medyaName}'),
                          ),
                        ],
                      ),
                    ),
                    CarouselSlider.builder(
                        itemCount: item.length,
                        options: CarouselOptions(
                          pageSnapping: true,
                          aspectRatio: 0.9,

                          //viewportFraction: 0.8,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          autoPlay: false,
                        ),
                        itemBuilder:
                            (BuildContext context, index, int pageViewIndex) {
                          switch (medyaType[index]) {
                            case 'image':
                              {
                                return Container(
                                    child: FadeInImage(
                                  image: NetworkImage(
                                      'https://drive.google.com/uc?id=' +
                                          '${medias[index]['url']}'),
                                  placeholder: AssetImage(
                                      'assets/images/album_dark.png'),
                                ));
                              }
                            case 'video':
                              {
                                return Container(
                                    child: FadeInImage(
                                  image: NetworkImage(
                                      'https://drive.google.com/uc?id=' +
                                          '${medias[index]['url']}'),
                                  placeholder: AssetImage(''),
                                ));
                              }
                            case 'audio':
                              {
                                return Container(
                                    child: FadeInImage(
                                  image: NetworkImage(
                                      'https://drive.google.com/uc?id=' +
                                          '${medias[index]['url']}'),
                                  placeholder: AssetImage(''),
                                ));
                              }
                            case 'txt':
                              {
                                return Container(
                                    child: FadeInImage(
                                  image: NetworkImage(
                                      'https://drive.google.com/uc?id=' +
                                          '${medias[index]['url']}'),
                                  placeholder: AssetImage(''),
                                ));
                              }
                            default:
                              {
                                return Container();
                              }
                          }
                        }),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(FontAwesomeIcons.heart)),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(FontAwesomeIcons.comment))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('${begeni} beğenme')),
                    ),
                    icerik != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text('Albüm İçeriği:${icerik!}')),
                          )
                        : Text('')
                  ],
                ),
              );
            })
      ],
    ));
  }
}
