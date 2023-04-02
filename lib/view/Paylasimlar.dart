import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../models/Album.dart';
import '../services/API2.dart';
import 'AudioView.dart';
import 'dart:typed_data';
import 'Yorumlar.dart';
import 'PdfView.dart';
import 'TxtView.dart';
import 'VideoPlayer.dart';

class Paylasimlar extends StatefulWidget {
  int? id;

  Paylasimlar({this.id});

  @override
  State<Paylasimlar> createState() => _PaylasimlarState();
}

class _PaylasimlarState extends State<Paylasimlar> {
  TextEditingController commentController = TextEditingController();
  List<dynamic> items = [];
  String token = '';
  dynamic user;
  dynamic userComments = {};

  List<dynamic> yorumlar = [];
  List<dynamic> yorumEkle = [];

  Future<void> getUser() async {
    String userString = await MyLocal.getStringData('user');
    user = json.decode(userString);
  }

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
    getUser();
    getSharesMedya();

    super.initState();
  }

  getKapak(dynamic item) {
    String type = item['type'];
    if (true) {
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
              enableInfiniteScroll: false,
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
              Medias mymedia = new Medias(
                path: mediaURL,
                fileType: media['type'],
                latitude: media['point']['coordinates'][1],
                longitude: media['point']['coordinates'][0],
                miniName: '',
                name: '',
                settings: json.encode(media['settings']),
                altitude: 0,
                album_id: 0,
              );

              String mediaType = media['type'];

              switch (mediaType) {
                case 'image':
                  {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(mediaURL),
                              fit: BoxFit.cover,
                            ),
                            color:
                            Theme
                                .of(context)
                                .bannerTheme
                                .backgroundColor),
                      ),
                    );
                  }
                case 'video':
                  {
                    //return await openVideo(mediaURL);
                    return Container(
                      child: MyVideoPlayer(
                        type: 'url',
                        path: mediaURL,
                        item: media,
                      ),
                    );
                  }

                case 'audio':
                  {
                    Medias mediam = new Medias(
                        album_id: 0,
                        name: '',
                        miniName: '',
                        fileType: 'audio',
                        path: mediaURL,
                        latitude: 0,
                        longitude: 0,
                        altitude: 0);
                    mediam.settings = json.encode(media['settings']);
                    return Container(
                      color: Theme
                          .of(context)
                          .scaffoldBackgroundColor,
                      child: AudioView(
                          appbarstatus: false, type: 'url', medias: mediam),
                    );
                  }
                case 'txt':
                  {
                    Medias mediax = Medias(
                        album_id: 0,
                        name: '',
                        miniName: '',
                        fileType: 'txt',
                        path: mediaURL,
                        latitude: 0,
                        longitude: 0,
                        altitude: 0);
                    mediax.settings = json.encode(media['settings']);
                    dynamic tip = json.decode(mediax.settings!);
                    if (tip['type'] == 'txt') {
                      return Container(
                        child: TxtView(
                          medias: mediax,
                          appbarstatus: false,
                          type: 'url',
                          item: media,
                        ),
                      );
                    } else {
                      return Container(
                        child: PdfView(
                          medias: mediax,
                          appbarstatus: false,
                          type: 'url',
                          item: media,
                        ),
                      );
                    }
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

  openVideo(String mediaURL) async {
    var response = await http.get(Uri.parse(mediaURL));
    List<int> bytes = response.bodyBytes;
    Uint8List buffer = Uint8List.fromList(bytes);
    return Container(
      child: Chewie(
        controller: ChewieController(
            videoPlayerController:
                VideoPlayerController.network(buffer.toString()),
            autoPlay: false,
            allowFullScreen: true,
            //fullScreenByDefault: true,
            autoInitialize: true,
            looping: false,
            aspectRatio: 0.7,
            errorBuilder: (context, errorMessage) {
              return Center(
                  child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ));
            },
            // allowFullScreen: true,
            additionalOptions: (context) {
              return <OptionItem>[
                //OptionItem(onTap: onTap, iconData: iconData, title: title)
              ];
            }),
      ),
    );
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

  getIcons(dynamic item, int index) {
    bool didILike = item['didILike'];
    List<Widget> iconlar = [];
    iconlar.add(IconButton(
      //padding:EdgeInsets.only(top:0,bottom: 0),
      onPressed: () async {
        dynamic gelen = await API
            .postRequest('api/lokomedia/like', {'share_id': item['id']});
        if (didILike == false) {
          item['didILike'] = true;
          item['like'] = gelen['data']['sayi'];
        } else {
          item['didILike'] = false;
          item['like'] = gelen['data']['sayi'];
        }
        setState(() {
          items[index] = item;
        });
      },
      icon: Icon(
        didILike == false ? Icons.favorite_border : Icons.favorite,
        color: didILike == false
            ? Theme.of(context).tabBarTheme.unselectedLabelColor
            : Colors.redAccent,
      ),
    ));
    iconlar.add(InkWell(
      highlightColor: Colors.black,
      splashColor: Colors.red,
      child: IconButton(
        //splashColor: Colors.red,
        //highlightColor: Colors.black,//Theme.of(context).listTileTheme.iconColor,
        onPressed: () async {
          getCommentRequest(item);
        },
        icon: Icon(Icons.mode_comment_outlined,
            color: Theme.of(context).tabBarTheme.unselectedLabelColor),
      ),
    ));
    if (item['point'] != null) {
      iconlar.add(IconButton(
        onPressed: () {},
        icon: Icon(Icons.map,
            color: Theme.of(context).tabBarTheme.unselectedLabelColor),
      ));
      iconlar.add(IconButton(
        onPressed: () {
          MapsLauncher.launchCoordinates(
              item['point']['coordinates'][1], item['point']['coordinates'][0]);
        },
        icon: Icon(Icons.navigation_outlined,
            color: Theme.of(context).tabBarTheme.unselectedLabelColor),
      ));
    }
    /*iconlar.add(IconButton(
      onPressed: () {},
      icon: Icon(Icons.share,
          color: Theme.of(context).tabBarTheme.unselectedLabelColor),
    ));*/
    return Container(
      // color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Row(
              children: iconlar,
            ),
          ),
          InkWell(
            child: IconButton(
              padding: EdgeInsets.only(top: 0, bottom: 0, right: 36),
              onPressed: () {},
              icon: Icon(Icons.delete,
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor),
            ),
          ),
        ],
      ),
    );
  }

  getTitleAndContent(dynamic item) {
    List<TextSpan> ekler = [];
    ekler.add(TextSpan(
      text: item['name'],
      style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall!.color,
          fontSize: 13,
          fontWeight: FontWeight.bold),
    ));
    ekler.add(TextSpan(
        text: item['content'] != null ? '-' : '',
        style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall!.color,
        )));
    ekler.add(TextSpan(
      text: item['content'],
      style: TextStyle(
          color: Theme.of(context).textTheme.headlineSmall!.color,
          fontSize: 12),
    ));
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: EdgeInsets.only(bottom: 10, left: 26, right: 22),
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(children: ekler),
      ),
    );
  }

  getLikes(dynamic item) {
    List<TextSpan> ekler = [];

    int likes = item['like'];

    if (likes == 0) {
      ekler.add(TextSpan(
        text: "a136".tr,
        style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall!.color,
            fontSize: 10),
      ));
    } else {
      ekler.add(TextSpan(
        text: likes == 1 ? '${likes}' + 'a242'.tr : '${likes}' + 'a243'.tr,
        style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall!.color,
            fontSize: 10),
      ));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: EdgeInsets.only(bottom: 10, left: 26, right: 32),
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(children: ekler),
      ),
    );
  }

  getComments(dynamic item, int index) {
    int comments = item['comment_num'];
    if (comments == 0) {
      TextEditingController commentContrlr = TextEditingController();
      return ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image(
            image: NetworkImage(user['img']),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        title: TextField(
          onChanged: (value) {
            userComments['yorum-'+item['id'].toString()] = value;

            //value = commentContrlr.text;
          },
          //controller: commentController,
          textAlign: TextAlign.left,
          keyboardType: TextInputType.text,
          cursorColor: Theme.of(context).textTheme.headlineSmall!.color,
          textCapitalization: TextCapitalization.words,
          maxLines: 1,
          decoration: InputDecoration(
            suffixIcon: TextButton(
              onPressed: () async {
                String text = userComments['yorum-'+item['id'].toString()];
                dynamic result = await API.postRequest(
                    'api/lokomedia/addComment', {
                  'share_id': item['id'],
                  'type': item['type'],
                  'comment': text
                });
                if (result['status'] == true) {
                  yorumEkle = result['data']['comments'];
                }
                item['comment_num']++;
                setState(() {
                  items[index]=item;
                  getCommentRequest(item);
                });
              },
              child: Text(
                'Paylaş',
                style: TextStyle(
                    color: Theme.of(context).listTileTheme.iconColor!),
              ),
            ),
            labelText: 'a244'.tr,
            labelStyle: TextStyle(
              color: Theme.of(context).listTileTheme.iconColor!,
            ),
            filled: true,
            fillColor: Theme.of(context).progressIndicatorTheme.color,
            contentPadding: EdgeInsets.all(8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(
                color: Theme.of(context).listTileTheme.iconColor!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).listTileTheme.iconColor!,
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          getCommentRequest(item);
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              comments == 1
                  ? '1 Yorumu Gör'
                  : '${comments} yorumun tümünü gör...',
              style: TextStyle(
                  color: Theme.of(context).textTheme.headlineSmall!.color,
                  fontSize: 12),
            ),
          ),
        ),
      );
    }
  }

  getCommentRequest(dynamic item) async {
    dynamic result = await API
        .postRequest('api/lokomedia/getComments', {'share_id': item['id']});
    if (result['status'] == true) {
      yorumlar = result['data']['comments'];
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Yorumlar(
                    comment: yorumlar,
                    user: user,
                    title: item['name'],
                    content: item['content'],
                    name: item['user'],
                    id: item['id'],
                  )));
    }
  }

  createItem(dynamic item, int index) {
    if (true) {
      if (item['medias'].length > 0) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            children: [
              getUserInfo(item),
              getKapak(item),
              getIcons(item, index),
              getLikes(item),
              getTitleAndContent(item),
              getComments(item, index),
            ],
          ),
        );
      }
    }
    return Container();
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
                              return createItem(items[i], i);
                            })
                      ],
                    ),
                  ),
                ),
              ));
  }
}
