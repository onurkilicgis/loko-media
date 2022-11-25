import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  late String imagePath;
  late String name;
  PhotoViewer({required this.imagePath, required this.name});
  @override
  _PhotoViewer createState() => _PhotoViewer();
}

class _PhotoViewer extends State<PhotoViewer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff202b40),
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
        child: Container(
          height: 200,
          color: Color(0xff202b40),
          width: 350,
          child: PhotoView(
            backgroundDecoration: BoxDecoration(color: Color(0xff202b40)),
            enableRotation: true,
            //disableGestures: true,
            //tightMode: true,
            imageProvider: FileImage(File(widget.imagePath.toString())),
          ),
        ),
      ),
    );
  }
}