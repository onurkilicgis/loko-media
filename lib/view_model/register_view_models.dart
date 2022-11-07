import 'package:flutter/cupertino.dart';

class CheckboxModel extends ChangeNotifier {
  bool _checkControl = false;

  bool get isCheckControl => _checkControl;

  set isCheckControl(bool value) {
    _checkControl = value;
    notifyListeners();
  }

  void checkboxChanged(bool data) {
    if (data != null) {
      isCheckControl = data;
    }
  }
}
