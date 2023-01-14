import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/view/app.dart';
import 'package:loko_media/view/register.dart';
import 'package:loko_media/view_model/layout.dart';

import '../models/Album.dart';
import '../services/API2.dart';
import '../services/utils.dart';

class VerifyScreen extends StatefulWidget {
  String email;
  String uid;

  VerifyScreen({Key? key, required this.email, required this.uid})
      : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _checkController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final TextEditingController _emailController =
        TextEditingController(text: widget.email);
    var ekranBilgisi = MediaQuery.of(context);
    final double ekranYuksekligi = ekranBilgisi.size.height;
    final double ekranGenisligi = ekranBilgisi.size.width;
    return Scaffold(
      backgroundColor: Color(0xff273238),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: ekranGenisligi,
                    height: ekranYuksekligi / 4,
                    child: Image.asset('images/korte_logo.png')),
                SizedBox(height: ekranYuksekligi / 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    obscureText: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? email
                            : null,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color(0xff80C783),
                    enabled: false,
                    style: TextStyle(
                      color: Color(0xff7C9099),
                    ),
                    controller: _emailController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: Color(0xff7C9099),
                        ),
                        hintText: 'a1'.tr,
                        hintStyle: TextStyle(color: Color(0xff7C9099))),
                  ),
                ),
                SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    obscureText: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp('[ ]')),
                    ],
                    maxLength: 6,
                    validator: (veri) {
                      if (veri!.isEmpty) {
                        return 'Lütfen onay kodunu giriniz.';
                      }

                      if (veri.isNum == false) {
                        return 'onay kodu sadece rakamlardan oluşmalıdır';
                      }

                      if (veri.length < 6 || veri.length > 6) {
                        return 'onay kodu  6 haneli olmalıdır.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xff80C783),
                    style: TextStyle(
                      color: Color(0xff7C9099),
                    ),
                    controller: _checkController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                        prefixIcon: Icon(
                          Icons.key,
                          color: Color(0xff7C9099),
                        ),
                        hintText: 'Onay kodu giriş alanı',
                        hintStyle: TextStyle(color: Color(0xff7C9099))),
                  ),
                ),
                SizedBox(
                  height: ekranYuksekligi / 25,
                ),
                Container(
                  child: SizedBox(
                    width: ekranGenisligi / 1.2,
                    height: ekranYuksekligi / 18,
                    child: ElevatedButton(
                      child: Text(
                        'Girilen Kodu Onayla',
                        style: TextStyle(
                            color: Color(0xff000200),
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        dynamic userApiControl = await API.postRequest(
                            'api/user/activation', {
                          'mail': widget.email,
                          'uid': widget.uid,
                          'code': _checkController.text
                        });
                        if (userApiControl['status'] == true) {
                          dynamic data = userApiControl['data'];
                          String user = json.encode(data);
                          String token = data['token'];
                          await MyLocal.setStringData('user', user);
                          await MyLocal.setStringData('token', token);
                          SBBildirim.onay(
                              'Mailiniz onaylanmıştır. Hoşgeldiniz sayın ${data['name']}.');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => App()));
                        } else {
                          SBBildirim.uyari(
                              'Onay kodu geçerli değil ya da eski bir zamana ait. Lütfen yeni kod alınız.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shadowColor: Colors.black,
                          elevation: 10,
                          primary: Color(0xff80C783),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))),
                    ),
                  ),
                ),
                SizedBox(
                  height: ekranYuksekligi / 30,
                ),
                Container(
                  child: SizedBox(
                    width: ekranGenisligi / 1.2,
                    height: ekranYuksekligi / 18,
                    child: ElevatedButton(
                      child: Text(
                        'Mail Adresime Tekrar \n Onay Kodu Gönder',
                        style: TextStyle(
                            color: Color(0xff000200),
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        Util.evetHayir(
                            context,
                            'Onay Kodu Gönderme',
                            'Belirtmiş olduğunuz ' +
                                widget.email +
                                ' mail adresine yeni bir onay kodu göndermek istediğinize emin misinz?',
                            (cevap) async {
                          if (cevap == true) {
                            dynamic userApiControl = await API.postRequest(
                                'api/user/activationmail',
                                {'mail': widget.email});
                            if (userApiControl['status'] == true) {
                              SBBildirim.bilgi(
                                  '${widget.email} adresine tekrar onay kodunu gönderdik.lütfen kontrol ediniz');
                            } else {
                              SBBildirim.hata(
                                  'Maalesef onay kodu gönderemedik. Daha sonra tekrar deneyiniz');
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          shadowColor: Colors.black,
                          elevation: 10,
                          primary: Color(0xff80C783),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))),
                    ),
                  ),
                ),
                SizedBox(
                  height: context.dynamicHeight(18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Üyeliğiniz Yok Mu?',
                          style: TextStyle(
                              color: Color(0xff7C9099),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(37)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      child: Container(
                        child: Text('a7'.tr,
                            style: TextStyle(
                                color: Color(0xff80C783),
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
