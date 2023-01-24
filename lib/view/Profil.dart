import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).progressIndicatorTheme.color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).progressIndicatorTheme.color,
        elevation: 0,
        title: Text('Onur Kılıç'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              child: Icon(Icons.more_horiz),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.person_remove_outlined,
                          ),
                          Text('Arkadaşlıktan Çıkart'),
                        ],
                      ),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.settings),
                          Text('Bilgilerimi Düzenle'),
                        ],
                      ),
                      value: 2,
                    )
                  ])
        ],
      ),
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 60, left: 100, right: 100, bottom: 20),
              child: CircleAvatar(
                radius: 70.0,
                backgroundImage: NetworkImage(
                    'https://i.pinimg.com/236x/e4/b8/a7/e4b8a72c6fb5f0a675e14d3585033400.jpg'),
                backgroundColor: Colors.transparent,
              )),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 25),
            child: Align(
                alignment: Alignment.center,
                child:
                    Opacity(opacity: 0.8, child: Text('simurgonur@gmail.com'))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '24',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Paylaşımlar',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Text(
                  '24',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Takipçi',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ]),
              Column(children: [
                Text(
                  '50',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Takip Edilenler',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ]),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Takip Et'),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
