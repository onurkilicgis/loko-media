import 'package:get/get_navigation/src/root/internacionalization.dart';

import '../lang/en.dart';
import '../lang/tr.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enLang,
        'tr_TR': trLang,
      };
}
