import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loko_media/view/app.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../services/utils.dart';
import '../view_model/MyHomePage_view_models.dart';
import '../view_model/register_view_models.dart';
import 'LoginPage.dart';
import 'WebPage.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _key = GlobalKey();

  // bool _isVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var ekranBilgisi = MediaQuery.of(context);
    final double ekranYuksekligi = ekranBilgisi.size.height;
    final double ekranGenisligi = ekranBilgisi.size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _key,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('a8'.tr,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff80C783))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('a9'.tr,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff7C9099))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          cursorColor: Color(0xff80C783),
                          obscureText: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: TextStyle(
                            color: Color(0xff7C9099),
                          ),
                          controller: _nameController,
                          validator: (veri) {
                            if (veri!.isEmpty) {
                              return 'Ad Soyad Zorunludur';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff7C9099)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff7C9099)),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xff7C9099),
                              ),
                              hintText: 'a10'.tr,
                              hintStyle: TextStyle(color: Color(0xff7C9099))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (veri) {
                            if (veri!.isEmpty) {
                              return 'a17'.tr;
                            }
                            return null;
                          },
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Color(0xff80C783),
                          style: TextStyle(
                            color: Color(0xff7C9099),
                          ),
                          controller: _emailController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff7C9099)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff7C9099)),
                              ),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: Color(0xff7C9099),
                              ),
                              hintText: 'a1'.tr,
                              hintStyle: TextStyle(color: Color(0xff7C9099))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<VisibleModel>(
                          builder: (context, visibleModel, child) {
                            return TextFormField(
                              cursorColor: Color(0xff80C783),
                              obscureText: visibleModel.isVisibleControl,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: TextStyle(color: Color(0xff7C9099)),
                              controller: _passwordController,
                              validator: (veri) {
                                if (veri!.isEmpty) {
                                  return 'Lütfen şifre giriniz.';
                                }

                                if (veri.length < 6) {
                                  return 'şifreniz en az 6 haneli olmalıdır.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        visibleModel.visibleChanged();
                                      },
                                      icon: visibleModel.isVisibleControl
                                          ? Icon(Icons.visibility_off,
                                              color: Colors.grey)
                                          : Icon(Icons.visibility,
                                              color: Colors.white)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff7C9099)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff7C9099)),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xff7C9099),
                                  ),
                                  hintText: 'a2'.tr,
                                  hintStyle:
                                      TextStyle(color: Color(0xff7C9099))),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 80, top: 20),
                        child: GestureDetector(
                            onTap: () {
                              String dil = Get.deviceLocale.toString();
                              var parca = dil.split('_')[0];
                              // sistemin dil bilgisini al
                              // switch içerisinde hangisine eşit ise o siteyi aç
                              // eğer yoksa default olarak en sayfasına gönder
                              String url = 'https://gislayer.com/term-of-use';
                              switch (parca) {
                                case 'tr':
                                  {
                                    url =
                                        'https://gislayer.com/tr/kullanim-kosullari';
                                    break;
                                  }
                                case 'es':
                                  {
                                    url =
                                        'https://gislayer.com/es/terminos-de-uso';
                                    break;
                                  }
                                case 'de':
                                  {
                                    url =
                                        'https://gislayer.com/de/nutzungsbedinungen';
                                    break;
                                  }
                                case 'ru':
                                  {
                                    url = 'https://gislayer.com/ru/term-of-use';
                                    break;
                                  }

                                case 'zh':
                                  {
                                    url = 'https://gislayer.com/ch/term-of-use';
                                    break;
                                  }
                                case 'ar':
                                  {
                                    url = 'https://gislayer.com/ar/term-of-use';
                                    break;
                                  }
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebPage(url: url)));
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Lütfen koşulları okuyunuz',
                                  style: TextStyle(
                                      color: Color(0xff7C9099),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Consumer<CheckboxModel>(
                            builder: (context, checkboxModel, child) {
                          return CheckboxListTile(
                            title: Text('a11'.tr,
                                style: TextStyle(color: Color(0xff7C9099))),
                            value: checkboxModel.isCheckControl,
                            controlAffinity: ListTileControlAffinity.leading,
                            secondary: Icon(Icons.beach_access),
                            checkColor: Color(0xff80C783),
                            activeColor: Color(0xff273238),
                            onChanged: (
                              bool? data,
                            ) {
                              checkboxModel.checkboxChanged(data!);
                            },
                          );
                        }),
                      ),
                      SizedBox(
                        width: ekranGenisligi / 1.2,
                        height: ekranYuksekligi / 18,
                        child: ElevatedButton(
                          child: Text(
                            'a12'.tr,
                            style: TextStyle(
                                color: Color(0xff000200),
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            String userName = _nameController.text;

                            if (_nameController.text == '') {
                              SBBildirim.uyari('Lütfen Ad Soyad giriniz');
                              return null;
                            }

                            if (_emailController.text == '') {
                              SBBildirim.uyari('Lütfen E-mail giriniz');
                              return null;
                            }
                            if (_passwordController.text == '') {
                              SBBildirim.uyari('Lütfen Şifre giriniz');
                              return null;
                            }
                            var checkModel = CheckboxModel();
                            if (checkModel.isCheckControl == false) {
                              SBBildirim.uyari('lütfen koşulları onaylayınız.');
                              return null;
                            }

                            _authService
                                .createPerson(
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text)
                                .then((value) {
                              return /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VerifyScreen(text: userName)))*/
                                  ;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: ekranYuksekligi / 30),
                      SizedBox(
                        width: ekranGenisligi / 1.2,
                        height: ekranYuksekligi / 18,
                        child: ElevatedButton.icon(
                          icon: Icon(FontAwesomeIcons.google,
                              color: Color(0xff000200)),
                          label: Text(
                            'a13'.tr,
                            style: TextStyle(
                                color: Color(0xff000200),
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await _authService.signInWithGoogle();
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => App()));
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: ekranYuksekligi / 30,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: ekranGenisligi / 5),
                            child: Container(
                              child: Text(
                                'a14'.tr,
                                style: TextStyle(
                                    color: Color(0xff7C9099),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(width: ekranGenisligi / 37),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            child: Container(
                              child: Text('a15'.tr,
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
            ],
          ),
        ),
      ),
    );
  }
}
