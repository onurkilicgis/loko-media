import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loko_media/services/utils.dart';

import '../models/Album.dart';

class TxtView extends StatefulWidget {
  late bool appbarstatus;
  late Medias medias;

  TxtView({required this.medias, required this.appbarstatus});

  @override
  State<TxtView> createState() => _TxtViewState();
}

class _TxtViewState extends State<TxtView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarstatus == true
          ? AppBar(
              title: Text(
                'Dosya İçeriği',
                style: TextStyle(fontSize: 23),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: ListView(children: [
          FutureBuilder(
            future: readTxt(widget.medias),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 430,
                    decoration: BoxDecoration(
                        color: Color(0xff2B3553),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Başlık :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Slabo27px',
                              fontSize: 17,
                              color: Color(0xff747d9c),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.medias.name!,
                            style: TextStyle(
                              fontFamily: 'Slabo27px',
                              fontSize: 14,
                              color: Color(0xffbabdc6),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'İçerik :',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Slabo27px',
                              fontSize: 17,
                              color: Color(0xff747d9c),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              fontFamily: 'Slabo27px',
                              fontSize: 14,
                              color: Color(0xffbabdc6),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ]),
      ),
    );
  }

  Future<String?> readTxt(Medias medias) async {
    try {
      final file = await File(medias.path!);

      final contents = await file.readAsString();

      return contents.toString();
    } catch (e) {
      // If encountering an error, return 0
      SBBildirim.hata(e.toString());
    }
  }
}
