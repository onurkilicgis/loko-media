import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../models/Album.dart';
import 'dart:typed_data';
import 'dart:io' as ioo;
import 'package:http/http.dart' as http;
import '../services/utils.dart';
import '../view_model/folder_model.dart';
class PdfView extends StatefulWidget {
  late bool appbarstatus;
  late Medias medias;
  String type;
  dynamic item;

  PdfView({required this.medias, required this.appbarstatus,required this.type,this.item});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late ioo.File file;
  late bool loadstatus = false;
  @override
  void initState() {
    readTxt(widget.medias);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarstatus == true
          ? AppBar(
              title: Text('a137'.tr),
            )
          : null,
      body: SafeArea(
        child: loadstatus==false ? Container():PDFView(
          filePath: widget.medias.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
        ),
      ),
    );
  }


  Future<String?> readTxt(Medias medias) async {
    try {
      if(widget.type=='url'){
        var response = await http.get(Uri.parse(medias.path!));
        List<int> bytes = response.bodyBytes;
        Uint8List buffer = Uint8List.fromList(bytes);
        String fakeFileName = widget.item['url'];
        String fakepath  = await FolderModel.getRootPath(fakeFileName);
        file  = new ioo.File(fakepath);
        file.writeAsBytesSync(buffer);
        widget.medias.path = fakepath;
        loadstatus=true;
        setState(() {

        });
      }else{
        loadstatus=true;
        setState(() {

        });
      }
    } catch (e) {
      // If encountering an error, return 0
      SBBildirim.hata(e.toString());
    }
  }
}
