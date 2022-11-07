import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loading {
  static void waiting(String text) {
    EasyLoading.show(status: text, maskType: EasyLoadingMaskType.black);
  }

  static void setText(String text) {
    //EasyLoading.instance.Te
  }

  static void close() {
    EasyLoading.dismiss();
  }
}
