import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

import '../models/Album.dart';

class PdfView extends StatefulWidget {
  late bool appbarstatus;
  late Medias medias;

  PdfView({required this.medias, required this.appbarstatus});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  bool _isLoading = true;
  PDFDocument? document;
  @override
  void initState() {
    loadPdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarstatus == true ? AppBar() : null,
      body: Center(
        child: _isLoading == true
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document!,
              ),
      ),
    );
  }

  loadPdf() async {
    File file = File(widget.medias.path!);
    document = await PDFDocument.fromFile(file);
    PDFPage pageOne = await document!.get(page: 1);
    setState(() {
      _isLoading = false;
      document = document;
    });
  }
}
