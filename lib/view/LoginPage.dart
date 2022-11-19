import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loko_media/view/app.dart';
import 'package:loko_media/view/register.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserRegistration.dart';
import '../services/Loader.dart';
import '../services/MyLocal.dart';
import '../services/api.dart';
import '../services/auth.dart';
import '../services/utils.dart';
import '../view_model/MyHomePage_view_models.dart';
import 'ForgetPasswordPage.dart';
import 'VerifyScreen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool tokenControl = false;
  bool loginControl = false;

  bool verify = false;
  var apiClass = API();

  bool isEntry = false;

  final auth = FirebaseAuth.instance;

  final TextEditingController _emailController =
      TextEditingController(text: 'onurkilic.gis@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '123456');
  AuthService _authService = AuthService();

  saveUserInfo(id, uid, mail, name, token) async {
    dynamic data = {
      'id': id,
      'uid': uid,
      'mail': mail,
      'name': name,
      'token': token
    };
    String dataString = json.encode(data);
    MyLocal.setStringData('user', dataString);
    MyLocal.setStringData('token', token);
  }

  //kullanıcı zaten sisteme girmiş mi diye kontrol için ilk başta çalıştırıyoruz.
  void loginControlState() async {
    String token = await MyLocal.getStringData('token');
    // token boş ise sisteme giriş yapan yok.
    if (token == '') {
      setState(() {
        // Loading ekranda circle olarak ortada dönen siyah dialogtur. bunu ekrandan silmek için kullanılır.
        Loading.close();
        // tokenControl
        tokenControl = true;
        loginControl = false;
      });
    } else {
      Loading.waiting('Giriş Kontrol Ediliyor');
      dynamic data = await apiClass.postRequest('api/v1/user/tokenControl', {});
      if (data['status'] == true) {
        dynamic usr = data['data'];
        dynamic usr2 = json.decode(usr);
        await saveUserInfo(
            usr2['id'], usr2['uid'], usr2['mail'], usr2['name'], usr2['token']);
        setState(() {
          Loading.close();
          tokenControl = true;
          loginControl = true;
        });
      } else {
        //Loading.close();
        SBBildirim.hata('Servise Ulaşılamıyor. API çalışmıyor.');
        Loading.close();
      }
    }
  }

  @override
  void initState() {
    //kullanıcı zaten sisteme girmiş mi diye kontrol için ilk başta çalıştırıyoruz.
    loginControlState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loginControl == true) {
      return App();
    } else {
      if (tokenControl == false) {
        return Container();
      } else {
        Loading.close();
        var ekranBilgisi = MediaQuery.of(context);
        final double ekranYuksekligi = ekranBilgisi.size.height;
        final double ekranGenisligi = ekranBilgisi.size.width;
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: ekranYuksekligi / 50),
                    child: SizedBox(
                        width: ekranGenisligi,
                        height: ekranYuksekligi / 4,
                        child: Image.asset('images/korte_logo.png')),
                  ),
                  SizedBox(
                    height: ekranYuksekligi / 20,
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: buildMailTextFormField(),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: buildPasswordTextFormField(),
                    ),
                  ),
                  buildPasswordGestureDetector(context, ekranGenisligi),
                  SizedBox(
                    height: ekranYuksekligi / 25,
                  ),
                  Container(
                    child: SizedBox(
                      width: ekranGenisligi / 1.2,
                      height: ekranYuksekligi / 18,
                      child: buildEntryElevatedButton(),
                    ),
                  ),
                  SizedBox(height: ekranYuksekligi / 30),
                  SizedBox(
                    width: ekranGenisligi / 1.2,
                    height: ekranYuksekligi / 18,
                    child: buildGoogleElevatedButton(),
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
                            'a6'.tr,
                            style: TextStyle(
                                color: Color(0xff7C9099),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: ekranGenisligi / 37),
                      buildSignGestureDetector(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  TextFormField buildMailTextFormField() {
    return TextFormField(
      enabled: !isEntry,
      obscureText: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) =>
          email != null && !EmailValidator.validate(email) ? 'a17'.tr : null,
      keyboardType: TextInputType.emailAddress,
      cursorColor: const Color(0xff80C783),
      style: const TextStyle(
        color: Color(0xff7C9099),
      ),
      controller: _emailController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff7C9099)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff7C9099)),
          ),
          prefixIcon: const Icon(
            Icons.mail_outline,
            color: Color(0xff7C9099),
          ),
          hintText: 'a1'.tr,
          hintStyle: const TextStyle(color: Color(0xff7C9099))),
    );
  }

  Consumer<VisibleModel> buildPasswordTextFormField() {
    return Consumer<VisibleModel>(builder: (context, visibleModel, child) {
      return TextFormField(
        enabled: !isEntry,
        cursorColor: const Color(0xff80C783),
        obscureText: visibleModel.isVisibleControl,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    ? const Icon(Icons.visibility_off, color: Colors.grey)
                    : const Icon(Icons.visibility, color: Colors.white)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7C9099)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7C9099)),
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Color(0xff7C9099),
            ),
            hintText: 'a2'.tr,
            hintStyle: const TextStyle(color: Color(0xff7C9099))),
      );
    });
  }

  ElevatedButton buildEntryElevatedButton() {
    return ElevatedButton(
      child: loadingButton(),
      onPressed: () {
        if (isEntry == false) {
          setState(() {
            isEntry = true;
          });
        } else {
          return null;
        }

        if (_emailController.text == '') {
          SBBildirim.uyari('Lütfen Mail Adresinizi Giriniz');
          return null;
        }
        if (_passwordController.text == '') {
          SBBildirim.uyari('Lütfen Şifrenizi Giriniz');
          return null;
        }

        _authService
            .signInPerson(_emailController.text, _passwordController.text)
            .then((value) async {
          String? uid = value?.uid;
          String? email = value?.email;
          dynamic result = await apiClass
              .postRequest('api/v1/user/login', {'email': email, 'uid': uid});
          if (result['status'] == false) {
            setState(() {
              isEntry = false;
            });
            if (result['errCode'] == 'err9') {
              if (email != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerifyScreen(email: email)));
              }
            }
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            UserRegistration loginModel = UserRegistration.fromJson(
                jsonDecode(result['data'].toString()));
            prefs.setString("user", result['data'].toString());
            prefs.setString("token", loginModel.token.toString());

            SBBildirim.onay('Hoşgeldiniz sayın ${loginModel.name}.');

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => App()));
          }
          print(result);
        }).catchError((onError) {
          setState(() {
            isEntry = false;
          });
          if (onError.message != '') {
            SBBildirim.hata(
              onError.message,
            );
          } else {
            switch (onError.code.toString()) {
              case 'unknown':
                {
                  SBBildirim.uyari(
                    'Lütfen Giriş Bilgilerinizi Kontrol Ediniz',
                  );
                  break;
                }
              case 'too-many-requests':
                {
                  SBBildirim.uyari(
                    'Çok Fazla Hatalı İstek Gönderdiniz. Lütfen Bir Süre Bekleyiniz',
                  );
                  break;
                }
              case 'wrong-password':
                {
                  SBBildirim.uyari(
                    'Girdiğiniz Parola Hatalıdır. Lütfen Şifrenizi Sıfırlayınız',
                  );
                  break;
                }
              case 'user-not-found':
                {
                  SBBildirim.uyari(_emailController.text +
                      ' Mail adresine ait bir kullanıcı bulunamadı. Lütfen Kayıt Olunuz');
                  break;
                }
            }
            print(onError);
          }
        });
      },
    );
  }

  GestureDetector buildPasswordGestureDetector(
      BuildContext context, double ekranGenisligi) {
    return GestureDetector(
      onTap: isEntry == true
          ? null
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ForgetPasswordPage(email: _emailController.text),
                  ));
            },
      child: Padding(
        padding: EdgeInsets.only(right: ekranGenisligi / 22),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Text(
            'a3'.tr,
            style: TextStyle(color: Color(0xff7C9099)),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildGoogleElevatedButton() {
    return ElevatedButton.icon(
      icon: const Icon(FontAwesomeIcons.google, color: Color(0xff000200)),
      label: Text(
        'a5'.tr,
        style: TextStyle(
            color: Color(0xff000200),
            fontSize: 17,
            fontWeight: FontWeight.bold),
      ),
      onPressed: isEntry == true ? null : GmailElevatedButton,
    );
  }

  void GmailElevatedButton() {
    if (isEntry == false) {
      setState(() {
        isEntry = true;
      });
    } else {
      return null;
    }

    _authService.signInWithGoogle().then((value) async {
      String? uid = value.user!.uid;
      String? email = value.user!.email;
      dynamic result = await apiClass
          .postRequest('api/v1/user/login', {'email': email, 'uid': uid});
      if (result['status'] == false) {
        setState(() {
          isEntry = false;
        });
        if (result['errCode'] == 'err9') {
          if (email != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyScreen(email: email)));
          }
        }
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        UserRegistration loginModel =
            UserRegistration.fromJson(jsonDecode(result['data'].toString()));
        prefs.setString("user", result['data'].toString());
        prefs.setString("token", loginModel.token.toString());

        SBBildirim.onay('Hoşgeldiniz sayın ${loginModel.name}.');

        Navigator.push(context, MaterialPageRoute(builder: (context) => App()));
      }
      print(result);
    }).catchError((onError) {
      setState(() {
        isEntry = false;
      });
      if (onError.message != '') {
        SBBildirim.hata(
          onError.message,
        );
      } else {
        switch (onError.code.toString()) {
          case 'unknown':
            {
              SBBildirim.uyari(
                'Lütfen Giriş Bilgilerinizi Kontrol Ediniz',
              );
              break;
            }
          case 'too-many-requests':
            {
              SBBildirim.uyari(
                'Çok Fazla Hatalı İstek Gönderdiniz. Lütfen Bir Süre Bekleyiniz',
              );
              break;
            }
          case 'wrong-password':
            {
              SBBildirim.uyari(
                'Girdiğiniz Parola Hatalıdır. Lütfen Şifrenizi Sıfırlayınız',
              );
              break;
            }
          case 'user-not-found':
            {
              SBBildirim.uyari(_emailController.text +
                  ' Mail adresine ait bir kullanıcı bulunamadı. Lütfen Kayıt Olunuz');
              break;
            }
        }
        print(onError);
      }
    });
  }

  GestureDetector buildSignGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: isEntry == true
          ? null
          : () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Register()));
            },
      child: Container(
        child: Text('a7'.tr,
            style: const TextStyle(
                color: Color(0xff80C783),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget loadingButton() {
    if (isEntry) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xff000200),
              ),
            ),
            SizedBox(width: 20),
            Text(
              ' Lütfen Bekleyiniz...',
              style: TextStyle(
                color: Color(0xff000200),
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        'a4'.tr,
        style: TextStyle(
            color: Color(0xff000200),
            fontSize: 17,
            fontWeight: FontWeight.bold),
      );
    }
  }
}
