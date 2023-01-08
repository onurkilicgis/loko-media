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
  List<dynamic> items = [];
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
      items = medya['data'];
    } else {
      items = [];
    }
    setState(() {});
  }

  @override
  void initState() {
    getSharesMedya();
    super.initState();
  }

  getKapak(dynamic item) {
    String type = item['type'];
    if (type == 'album') {
      String kapakUrl = item['kapak']['url'];
      int kapakIndex = 0;
      int medyaSayisi = item['medias'].length;
      for (int i = 0; i < medyaSayisi; i++) {
        dynamic media = item['medias'][i];
        if (media['url'] == kapakUrl) {
          kapakIndex = i;
          break;
        }
      }
      dynamic medias = item['medias'];
      return CarouselSlider.builder(
          itemCount: medyaSayisi,
          options: CarouselOptions(
            pageSnapping: true,
            aspectRatio: 0.9,
            initialPage: kapakIndex,
            //viewportFraction: 0.8,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            autoPlay: false,
          ),
          itemBuilder: (BuildContext context, index, int pageViewIndex) {
            dynamic media = medias[index];
            String mediaURL = 'https://drive.google.com/uc?id=${media['url']}';
            String mediaType = media['type'];
            switch (mediaType) {
              case 'image':
                {
                  return Container(
                      child: FadeInImage(
                    image: NetworkImage(mediaURL),
                    placeholder: AssetImage('assets/images/album_dark.png'),
                  ));
                }
              default:
                {
                  return Container();
                }
            }
          });
    } else {}
  }

  createItem(dynamic item) {
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
                          backgroundImage: NetworkImage(item['user']['img'])),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item['user']['name']),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item['name']),
                ),
              ],
            ),
          ),
          getKapak(item),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.heart)),
              IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.comment))
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: item['like'] == 0
                    ? Text('Beğeni Yok')
                    : Text('${item['like']} beğenme')),
          ),
          item['content'].toString().isNotEmpty == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(item['content'])),
                )
              : Text('')
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return createItem(items[index]);
            })
      ],
    ));
  }
}
