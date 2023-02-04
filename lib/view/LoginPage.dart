import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loko_media/view/app.dart';
import 'package:loko_media/view/register.dart';
import 'package:provider/provider.dart';

import '../services/API2.dart';
import '../services/Loader.dart';
import '../services/MyLocal.dart';
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
  bool isEntry = false;
  String isDark = 'dark';

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
    isDark = await MyLocal.getStringData('theme');
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
      bool internetStatus = await InternetConnectionChecker().hasConnection;
      if (internetStatus == true) {
        Loading.waiting('a19'.tr);
        String userString = await MyLocal.getStringData('user');
        dynamic user = json.decode(userString);
        firebaseLogin(user['mail'], user['id'], user['name']);
        Loading.close();
      } else {
        String userString = await MyLocal.getStringData('user');
        dynamic user = json.decode(userString);
        if (user['uid'] != '') {
          setState(() {
            Loading.close();
            tokenControl = true;
            loginControl = true;
          });
        }
      }
    }
  }

  firebaseLogin(String email, String uid, String name) async {
    dynamic userApiControl = await API.postRequest(
        'api/user/login', {'mail': email.toString(), 'uid': uid.toString()});
    if (userApiControl['status'] == false) {
      setState(() {
        isEntry = false;
      });
      switch (userApiControl['message']) {
        case 'err000003':
          {
            dynamic dbUser = await API.postRequest('api/user/register', {
              'mail': email.toString(),
              'uid': uid.toString(),
              'name': name
            });
            if (dbUser['status'] == true) {
              SBBildirim.bilgi(email + 'a20'.tr);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifyScreen(
                            email: email,
                            uid: uid.toString(),
                          )));
            }
            break;
          }
        case 'err000005':
          {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VerifyScreen(email: email, uid: uid.toString())));
            break;
          }
      }
    } else {
      setState(() {
        isEntry = false;
      });
      dynamic data = userApiControl['data'];
      String user = json.encode(data);
      String token = data['token'];
      await MyLocal.setStringData('user', user);
      await MyLocal.setStringData('token', token);
      SBBildirim.onay(
          Utils.getComplexLanguage('a21'.tr, {'isim': '${data['name']}.'}));
      Navigator.push(context, MaterialPageRoute(builder: (context) => App()));
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
                  SizedBox(
                      height: ekranYuksekligi / 6,
                      child: Image.asset(isDark=='dark'?'images/lokomedia-logo3.png':'images/lokomedia-logo.png')),
                  SizedBox(
                    height: ekranYuksekligi / 8,
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
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
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
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[ ]')),
        ],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: TextStyle(color: Color(0xff7C9099)),
        controller: _passwordController,
        validator: (veri) {
          if (veri!.isEmpty) {
            return 'a22'.tr;
          }

          if (veri.length < 6) {
            return 'a23'.tr;
          }
          return null;
        },
        decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () {
                  visibleModel.visibleChanged();
                },
                icon: visibleModel.isVisibleControl == false
                    ? const Icon(Icons.visibility, color: Colors.white)
                    : const Icon(Icons.visibility_off, color: Colors.grey)),
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
      onPressed: () async {
        if (isEntry == false) {
          setState(() {
            isEntry = true;
          });
        } else {
          return null;
        }

        if (_emailController.text == '') {
          SBBildirim.uyari('a24'.tr);
          return null;
        }
        if (_passwordController.text == '') {
          SBBildirim.uyari('a25'.tr);
          return null;
        }

//
        User? user = await _authService
            .signInPerson(_emailController.text, _passwordController.text, () {
          setState(() {
            isEntry = false;
          });
        });
        firebaseLogin(user!.email.toString(), user.uid.toString(), 'Unnamed');
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

  void GmailElevatedButton() async {
    if (isEntry == false) {
      setState(() {
        isEntry = true;
      });
    } else {
      return null;
    }
    var user = await _authService.signInWithGoogle();
    if (user != null) {
      firebaseLogin(user.user!.email.toString(), user.user!.uid.toString(),
          user.user!.displayName.toString());
    } else {
      setState(() {
        isEntry = false;
      });
    }
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
              'a26'.tr,
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
