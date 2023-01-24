import 'package:flutter/cupertino.dart';

class SwitchModel extends ChangeNotifier {
  late String userSelection;
  bool _switchControl = false;
  bool get isSwitchControl => _switchControl;
  SwitchModel({required this.userSelection}) {
    if (this.userSelection == 'dark') {
      this._switchControl = false;
    } else {
      this._switchControl = true;
    }
  }

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
