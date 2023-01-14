import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../models/Album.dart';

class PdfView extends StatefulWidget {
  late bool appbarstatus;
  late Medias medias;

  PdfView({required this.medias, required this.appbarstatus});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarstatus == true
          ? AppBar(
              title: Text('Pdf Dosya İçeriği'),
            )
          : null,
      body: SafeArea(
        child: PDFView(
          filePath: widget.medias.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
        ),
      ),
    );
  }
}
