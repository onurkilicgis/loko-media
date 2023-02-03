import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../services/auth.dart';
import '../services/utils.dart';

class ForgetPasswordPage extends StatefulWidget {
  late String email;

  ForgetPasswordPage({required this.email});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  late final emailcontroller = TextEditingController();
  AuthService _authService = AuthService();

  @override
  void dispose() {
    emailcontroller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    var ekranBilgisi = MediaQuery.of(context);
    final double ekranYuksekligi = ekranBilgisi.size.height;
    final double ekranGenisligi = ekranBilgisi.size.width;
    late final emailcontroller = TextEditingController(text: widget.email);
    return Scaffold(
        backgroundColor: Color(0xff273238),
        body: SafeArea(
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: ekranGenisligi,
                      height: ekranYuksekligi / 4,
                      child: Image.asset('images/korte_logo.png')),
                  SizedBox(height: ekranYuksekligi / 15),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'a16'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff7C9099),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: ekranYuksekligi / 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: emailcontroller,
                      cursorColor: Color(0xff7C9099),
                      style: TextStyle(
                        color: Color(0xff7C9099),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: Color(0xff7C9099),
                        ),
                        hintText: 'a1'.tr,
                        hintStyle: TextStyle(color: Color(0xff7C9099)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff7C9099)),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'a17'.tr
                              : null,
                    ),
                  ),
                  SizedBox(
                    height: ekranYuksekligi / 25,
                  ),
                  Container(
                    child: SizedBox(
                      width: ekranGenisligi / 1.2,
                      height: ekranYuksekligi / 18,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            if (emailcontroller.text == '') {
                              SBBildirim.uyari('a24'.tr);
                              return null;
                            }

                            _authService
                                .signInPerson(emailcontroller.text,
                                    'aşkdsjşaldbfKŞJQWBKJABDVKBqhuew')
                                .then((value) => null)
                                .catchError((onError) {
                              switch (onError.code.toString()) {
                                case 'wrong-password':
                                  {
                                    _authService
                                        .sendPasswordResetEmail(
                                            emailcontroller.text)
                                        .then((a) => {
                                              SBBildirim.uyari(
                                                  Utils.getComplexLanguage(
                                                      'a106'.tr, {
                                                'mail': emailcontroller.text
                                              })),
                                              Navigator.of(context).pop()
                                            });

                                    break;
                                  }
                                case 'user-not-found':
                                  {
                                    SBBildirim.uyari(Utils.getComplexLanguage(
                                        'a107'.tr,
                                        {'mail': emailcontroller.text}));
                                    break;
                                  }
                              }
                            });
                          },
                          icon: Icon(
                            Icons.email_outlined,
                            color: Color(0xff000200),
                          ),
                          label: Text(
                            'a18'.tr,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff000200)),
                          )),
                    ),
                  )
                ],
              )),
        ));
  }
}
