import 'package:flutter/cupertino.dart';

class Harita extends StatefulWidget {
  //const Harita({Key? key}) : super(key: key);
  final int id;
  final String type;
  Harita({required this.id,required this.type});
  @override
  State<Harita> createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
