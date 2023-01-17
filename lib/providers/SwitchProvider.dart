import 'package:flutter/cupertino.dart';

class SwitchModel extends ChangeNotifier {
  bool _switchControl = false;

  bool get isSwitchControl => _switchControl;

  set isSwitchControl(bool value) {
    _switchControl = value;
    notifyListeners(); //tetikleyici, yani dinleyicileri bilgilendir.
  }

  void switchChanged(bool data) {
    // dinleyici, yani switchi değiştirmeyi kabul eden.
    if (data != null) {
      isSwitchControl = data;
    }
  }
}
