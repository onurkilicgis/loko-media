import 'package:flutter/cupertino.dart';

class SwitchModel extends ChangeNotifier {
  late String userSelection;
  String _switchControl = 'dark';
  bool get isSwitchControl => _switchControl=='dark'?true:false;
  SwitchModel({required this.userSelection}) {
    if (this.userSelection == 'dark') {
      this._switchControl = 'dark';
    } else {
      this._switchControl = 'light';
    }
  }

  set isSwitchControl(bool value) {
    if(value==true){
      _switchControl = 'dark';
    }else {
      _switchControl = 'light';
    }
    notifyListeners(); //tetikleyici, yani dinleyicileri bilgilendir.
  }

  void switchChanged(bool data) {
    // dinleyici, yani switchi değiştirmeyi kabul eden.
    if (data != null) {
      isSwitchControl = data;
    }
  }
}
