import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/services/MyLocal.dart';

import '../services/API2.dart';

class Paylasimlar extends StatefulWidget {
  int? id;

  Paylasimlar({this.id});

  @override
  State<Paylasimlar> createState() => _PaylasimlarState();
}

class _PaylasimlarState extends State<Paylasimlar> {
  List<dynamic> items = [];
  String token = '';
  getSharesMedya() async {
    dynamic medya =
        await API.postRequest("api/lokomedia/getShares", {'offset': "0"});
    if (medya['status'] == true) {
      items = medya['data'];
    } else {
      items = [];
    }
    setState(() {});
  }

  getToken() async {
    token = await MyLocal.getStringData('token');
    setState(() {});
  }

  @override
  void initState() {
    getToken();
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
      return Container(
        child: CarouselSlider.builder(
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
              String mediaURL =
                  API.generateStorageFileUrl(token, media['fid'].toString());
              String mediaType = media['type'];
              switch (mediaType) {
                case 'image':
                  {
                    //drive.getAFile(media['url']);
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(mediaURL),
                              fit: BoxFit.cover,
                            ),
                            color:
                                Theme.of(context).bannerTheme.backgroundColor),
                      ),
                    );
                  }
                default:
                  {
                    return Container();
                  }
              }
            }),
      );
    } else {}
  }

  getUserInfo(dynamic item) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image(
                  image: NetworkImage(item['user']['img']),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(item['user']['name']),
            ],
          ),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  getIcons(dynamic item) {
    List<Widget> iconlar = [];
    iconlar.add(IconButton(
      //padding:EdgeInsets.only(top:0,bottom: 0),
      onPressed: () {},
      icon: Icon(
        Icons.favorite_border,
        color: Theme.of(context).tabBarTheme.unselectedLabelColor,
      ),
    ));
    iconlar.add(IconButton(
      onPressed: () {},
      icon: Icon(Icons.mode_comment_outlined,
          color: Theme.of(context).tabBarTheme.unselectedLabelColor),
    ));
    if (item['point'] != null) {
      iconlar.add(IconButton(
        onPressed: () {},
        icon: Icon(Icons.map,
            color: Theme.of(context).tabBarTheme.unselectedLabelColor),
      ));
      iconlar.add(IconButton(
        onPressed: () {},
        icon: Icon(Icons.navigation_outlined,
            color: Theme.of(context).tabBarTheme.unselectedLabelColor),
      ));
    }
    iconlar.add(IconButton(
      onPressed: () {},
      icon: Icon(Icons.share,
          color: Theme.of(context).tabBarTheme.unselectedLabelColor),
    ));
    return Container(
      // color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: iconlar,
          ),
          InkWell(
            child: IconButton(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              onPressed: () {},
              icon: Icon(Icons.delete,
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor),
            ),
          ),
        ],
      ),
    );
  }

  getTitleAndComment(dynamic item) {
    List<TextSpan> ekler = [];
    ekler.add(TextSpan(
      text: item['name'],
      style: TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
    ));
    ekler.add(TextSpan(text: ' - '));
    ekler.add(TextSpan(
      text: item['content'],
      style: TextStyle(color: Colors.white, fontSize: 12),
    ));
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: EdgeInsets.only(bottom: 10),
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(children: ekler),
      ),
    );
  }

  getLikesAndComments(dynamic item) {
    List<TextSpan> ekler = [];
    List<dynamic> yorumlar = [];
    int likes = item['like'];
    if (likes == 0) {
      ekler.add(TextSpan(
        text: "a136".tr,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: EdgeInsets.only(bottom: 10),
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(children: ekler),
      ),
    );
  }

  createItem(dynamic item) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          getUserInfo(item),
          getKapak(item),
          getIcons(item),
          getTitleAndComment(item),
          getLikesAndComments(item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: token == ''
            ? Container()
            : SafeArea(
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) {
                              return createItem(items[i]);
                            })
                      ],
                    ),
                  ),
                ),
              ));
  }
}
