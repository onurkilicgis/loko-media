import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SBBildirim {
  static void hata(String icerik) {
    String zaman = 'static';
    Color renk = Color(0xfff44336);
    String baslik = 'Önemli Uyarı!';
    run(baslik, icerik, zaman, renk);
  }

  static void uyari(String icerik) {
    String zaman = 'auto';
    Color renk = Color(0xffffc107);
    String baslik = 'Önemli Uyarı!';
    run(baslik, icerik, zaman, renk);
  }

  static void onay(String icerik) {
    String zaman = 'auto';
    Color renk = Color(0xff8bc34a);
    String baslik = 'Başarılı İşlem!';
    run(baslik, icerik, zaman, renk);
  }

  static void bilgi(String icerik) {
    String zaman = 'auto';
    Color renk = Color(0xff00bcd4);
    String baslik = 'Önemli Bilgilendirme!';
    run(baslik, icerik, zaman, renk);
  }

  static void run(
      String baslik, String icerik, String timeType, Color yaziRengi) {
    // timeType eğer 'static' ise ekranda sürekli kalacak
    // timeType eğer 'auto' ise kelime sayısına göre gösterilecek ve kendisi kapanacak
    // timeType eğer yukarıdakilerden biri değilse veilen zaman kullanılacak
    int zaman = 0;
    if (timeType == 'static') {
      zaman = 99999;
    } else if (timeType == 'auto') {
      int kelimeSayisi = icerik.split(' ').length;
      zaman = kelimeSayisi * 1;
    } else {
      zaman = int.parse(timeType);
    }

    Get.snackbar(baslik, icerik,
        colorText: yaziRengi,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xff1e272b),
        duration: Duration(seconds: zaman),
        borderRadius: 5,
        margin: EdgeInsets.only(top: 5, left: 5, right: 5));
  }
}

class AlertBildirim {
  static void hata(String icerik, List<Widget> butonlar) {
    Color renk = Color(0xfff44336);
    String baslik = 'Önemli Uyarı!';
    run(baslik, icerik, renk, butonlar);
  }

  static void uyari(String icerik, List<Widget> butonlar) {
    Color renk = Color(0xffffc107);
    String baslik = 'Önemli Uyarı!';
    run(baslik, icerik, renk, butonlar);
  }

  static void onay(String icerik, List<Widget> butonlar) {
    Color renk = Color(0xff8bc34a);
    String baslik = 'Başarılı İşlem!';
    run(baslik, icerik, renk, butonlar);
  }

  static void bilgi(String icerik, List<Widget> butonlar) {
    Color renk = Color(0xff00bcd4);
    String baslik = 'Önemli Bilgilendirme!';
    run(baslik, icerik, renk, butonlar);
  }

  static void run(
      String baslik, String icerik, Color renk, List<Widget> butonlar) {
    Get.defaultDialog(
      title: baslik,
      titleStyle: TextStyle(fontSize: 19, color: renk),
      middleText: icerik,
      middleTextStyle: TextStyle(fontSize: 15, color: renk),
      backgroundColor: Color(0xff1e272b),
      radius: 5,
      // textCancel: 'kapat',
      // cancelTextColor: Colors.red,
      //onCancel: () {},
      // textConfirm: 'kabul et',
      // confirmTextColor: Colors.green,
      // onConfirm: () {},
      actions: butonlar,
      cancel: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
              elevation: 10,
              primary: Color(0xff80C783),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)))),
          child: Text(
            'Kapat',
            style: TextStyle(
                color: Color(0xff000200),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          )),
    );
  }
}
