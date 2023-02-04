import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:loko_media/providers/SwitchProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import '../database/AlbumDataBase.dart';
import '../providers/MedyaProvider.dart';
import '../services/MyLocal.dart';
import '../view_model/MyHomePage_view_models.dart';
import '../view_model/folder_model.dart';
import '../view_model/multi_language.dart';
import '../view_model/register_view_models.dart';
import '../view_model/theme.dart';
import 'LoginPage.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print(data);

  if (data?.host == 'titleclicked') {
    final greetings = [
      'Hello',
      'Hallo',
      'Bonjour',
      'Hola',
      'Ciao',
      '哈洛',
      '안녕하세요',
      'xin chào'
    ];
    final selectedGreeting = greetings[Random().nextInt(greetings.length)];

    await HomeWidget.saveWidgetData<String>('title', selectedGreeting);
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  // localhost:1990/index.html harita dosyalarımızı yayınlanladımız yer.
  InAppLocalhostServer localhostServer = InAppLocalhostServer(
      port: 1990,
      documentRoot: './assets/harita/',
      directoryIndex: 'index.html');

  // indirdiğimiz resimleri ve klasörleri webview tarafında localhost:1991/albüm_adı/resim şelinde ulaşabileceğimiz kanalı açıyor.
  final Directory root = await getApplicationDocumentsDirectory();
  final Directory albumPath = Directory('${root.path}/albums');
  final server = LocalAssetsServer(
    address: InternetAddress.loopbackIPv4,
    assetsBasePath: albumPath.path,
    rootDir: albumPath,
    port: 1991,
    logger: const DebugLogger(),
  );
  final srv = await server.serve();

  // Uygulamanın root'unda albüm adında bir klasör oluşturur.
  await FolderModel.createFolder('albums');
  // assets/.env.development içerisinde ki bilgileri daha sonra kullanmak için okuyor
  // Note : burada production için ayrı development için ayrı dosyayı yüklemen gerekir. kodları baklan_flutter uygulamasında var
  await dotenv.load(fileName: "assets/.env.development");
  await AlbumDataBase.createTables();

  // Program ilk kullanıldığında 'theme' keyinin bir değeri yoktur.
  // Kullanıcının tema konusunda yapmış olduğu seçimi aklında tutmuş oluyor.
  String isDark = await MyLocal.getStringData('theme');
  String cardType = await MyLocal.getStringData('card-type');
  if (cardType == '') {
    await MyLocal.setStringData('card-type', 'GFCard');
  }
  if (isDark == '') {
    await MyLocal.setStringData('theme', 'dark');
    isDark = 'dark';
  }

  // loko media logosunu siliyor.
  FlutterNativeSplash.remove();

  // izinler kullanıcıdan isteniyor.
  await Permission.camera.request(); //ok
  await Permission.microphone.request(); //ok
  await Permission.storage.request(); //ok buna gerek yok gibi
  await Permission.location.request(); //ok

  await Firebase.initializeApp();
  await localhostServer.start();

  runApp(MyApp(isDark: isDark));
}

Future initialization(BuildContext, context) async {
  await Future.delayed(const Duration(milliseconds: 500));
}

class MyApp extends StatefulWidget {
  late String isDark;
  MyApp({required this.isDark});

  @override
  _MyAppState createState() {
    return _MyAppState(isDark: isDark);
  }
}

class _MyAppState extends State<MyApp> {
  String isDark;

  _MyAppState({required this.isDark});

  @override
  void initState() {
    super.initState();
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => SwitchModel(userSelection: this.isDark)),
          ChangeNotifierProvider(create: (context) => CheckboxModel()),
          ChangeNotifierProvider(create: (context) => VisibleModel()),
          ChangeNotifierProvider(create: (context) => MediaProvider()),
        ],
        child: Consumer<SwitchModel>(builder: (context, switchModels, child) {
          return GetMaterialApp(
            theme: switchModels.isSwitchControl == true
                ? MyTheme.darkTheme
                : MyTheme.lightTheme,
            title: 'LOKO MEDIA',
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
            builder:
                EasyLoading.init(), // ekranın ortasında loading göstermek için.
          );
        }));
  }
}
