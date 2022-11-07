import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../view_model/MyHomePage_view_models.dart';
import '../view_model/main_view_models.dart';
import '../view_model/multi_language.dart';
import '../view_model/register_view_models.dart';
import '../view_model/theme.dart';
import 'LoginPage.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env.development");
  //await dotenv.load(fileName: Environment.env);
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.remove();

  await Firebase.initializeApp();
  runApp(MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future initialization(BuildContext, context) async {
  await Future.delayed(const Duration(milliseconds: 500));
}

class MyApp extends StatelessWidget {
  SwitchModel switchModels = SwitchModel();
  // MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SwitchModel()),
          ChangeNotifierProvider(create: (context) => CheckboxModel()),
          ChangeNotifierProvider(create: (context) => VisibleModel())
        ],
        child: Consumer<SwitchModel>(builder: (context, switchModels, child) {
          return GetMaterialApp(
            theme: switchModels.isSwitchControl == false
                ? MyTheme.darkTheme
                : MyTheme.lightTheme,
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            translations: Messages(),
            locale: Get.deviceLocale,
            fallbackLocale: Locale('en', 'US'),
            home: StreamBuilder(
                stream: FirebaseAuth.instance
                    .authStateChanges(), //kullanıcı çıkış yapmamışsa uygulama kapansada anasayfada tutuyor
                builder: (context, userSnp) {
                  return LoginPage();
                }),
            builder: EasyLoading.init(),
          );
        }));
  }
}
