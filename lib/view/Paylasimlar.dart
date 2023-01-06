import 'package:flutter/material.dart';

class Paylasimlar extends StatefulWidget {
  int? id;

  Paylasimlar({this.id});

  @override
  State<Paylasimlar> createState() => _PaylasimlarState();
}

class _PaylasimlarState extends State<Paylasimlar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: Center(
          child: Container(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage('')),
                              Text('')
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ));
  }
}
