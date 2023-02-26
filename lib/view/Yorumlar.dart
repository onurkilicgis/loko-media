import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loko_media/services/utils.dart';
import 'package:provider/provider.dart';

import '../models/Album.dart';
import '../providers/SwitchProvider.dart';
import '../services/API2.dart';

class Yorumlar extends StatefulWidget {
  List<dynamic> comment = [];
  Map<String, dynamic> name;
  dynamic user;
  String title;
  String content;
  int id;

  Yorumlar(
      {required this.comment,
      required this.name,
      required this.user,
      required this.title,
      required this.id,
      required this.content});

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController commentController = TextEditingController();
  List<dynamic> yorumEkle = [];

  bool isVisible = true;

  @override
  void initState() {
    super.initState();

    /*  Future.delayed(Duration.zero, () {
      getBottomSheet();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Yorumlar'),
        centerTitle: true,
        actions: [
          Consumer<SwitchModel>(builder: (context, switchModel, child) {
            return IconButton(
                onPressed: () {
                  getBottomSheet();
                  switchModel.isVisible = true;
                },
                icon: Icon(Icons.add_circle_outline_rounded));
          })
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image(
                image: NetworkImage(widget.name['img']),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            title: Column(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Text(widget.user['name'])),
                Row(
                  children: [
                    Text(widget.title),
                    Text('-'),
                    Text(widget.content)
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.comment.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime pastDateTime =
                    DateTime.parse(widget.comment[index]['tarih']);
                DateTime now = DateTime.now();
                Duration difference = now.difference(pastDateTime);
                var days = difference.inDays;
                var hours = difference.inHours % 24;

                return ListTile(
                  onLongPress: () {
                    Util.evetHayir(context, 'Yorum Silme',
                        'Silmek İstediğinize Emin Misiniz?', (cevap) async {
                      if (cevap == true) {
                        SBBildirim.bilgi('Yorum silindi');
                      }
                    });
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image(
                      image: NetworkImage(widget.comment[index]['img']),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        widget.comment[index]['name'],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$days' + 'g' + ' ' + '$hours' + 's'),
                      )
                    ],
                  ),
                  subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.comment[index]['text'],
                        style: TextStyle(fontSize: 15),
                      )),
                );
              }),
          isVisible == true ? getBottomSheet() : Container()
        ],
      )),
    );
  }

  getBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).listTileTheme.tileColor,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return ListTile(
            tileColor: Theme.of(context).scaffoldBackgroundColor,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image(
                image: NetworkImage(widget.user['img']),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              child: TextField(
                //scrollPadding: EdgeInsets.only(bottom: .0),
                onChanged: (value) {
                  value = commentController.text;
                },
                controller: commentController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                cursorColor: Theme.of(context).textTheme.headline5!.color,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                decoration: InputDecoration(
                  suffixIcon: Consumer<SwitchModel>(
                      builder: (context, switchModel, child) {
                    return TextButton(
                      onPressed: () async {
                        dynamic result = await API.postRequest(
                            'api/lokomedia/addComment', {
                          'share_id': widget.id,
                          'comment': commentController.text
                        });
                        if (result['status'] == true) {
                          yorumEkle = result['data']['comments'];

                          switchModel.isVisible = false;
                        }
                      },
                      child: Text(
                        'Paylaş',
                        style: TextStyle(
                            color: Theme.of(context).listTileTheme.iconColor!),
                      ),
                    );
                  }),
                  labelText: 'a244'.tr,
                  labelStyle: TextStyle(
                    color: Theme.of(context).listTileTheme.iconColor!,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).appBarTheme.backgroundColor,
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
            ),
          );
        });
  }
}
