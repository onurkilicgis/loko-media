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

  getSharesMedya() async {
    dynamic medya =
        await API.postRequest("api/lokomedia/getShares", {'offset': 0});
    if (medya['status'] == true) {
      item = medya['data'];
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
        appBar: AppBar(
          title: Text(''),
        ),
        body: Center(
          child: Container(
            child: ListView.builder(
                itemCount: item.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage('')),
                              Text('')
                            ],
                          ),
                        ),
                        FadeInImage(
                          image: NetworkImage(''),
                          placeholder: AssetImage(''),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FontAwesomeIcons.heart)),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FontAwesomeIcons.comment))
                          ],
                        )
                      ],
                    ),
                  );
                }),
          ),
        ));
  }
}
