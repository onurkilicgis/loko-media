import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'LoginPage.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late SpinKitSquareCircle spinkit;

  @override
  void initstate() {
    spinkit = SpinKitSquareCircle(
        color: Colors.black87,
        size: 50.0,
        controller: AnimationController(
            vsync: this,
            duration: const Duration(
                milliseconds:
                    1000)) //vsync ile asıl ekran görüntülenmeden animasyon engellenir.single ticker ile animasyonu haberdar ederiz
        );
  }

  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () async {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
    return Scaffold(
        body: Center(
            child: Column(
      children: [spinkit],
    )));
  }
}
