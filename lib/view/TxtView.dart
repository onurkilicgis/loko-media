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
      body: ListView(children: [
        FutureBuilder(
          future: readTxt(widget.medias),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff2B3553),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 15, bottom: 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.medias.name!,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 8, right: 8, bottom: 30),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${snapshot.data}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
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
